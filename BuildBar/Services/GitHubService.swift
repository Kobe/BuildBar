//
//  GitHubService.swift
//  BuildBar
//
//  GitHub REST API client for fetching workflow runs
//

import Foundation

enum GitHubError: LocalizedError {
    case noToken
    case invalidToken
    case networkError(Error)
    case rateLimited(resetDate: Date)
    case apiError(statusCode: Int, message: String)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .noToken:
            return "No GitHub token configured. Go to Settings."
        case .invalidToken:
            return "GitHub token is invalid or expired."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimited(let reset):
            let formatter = RelativeDateTimeFormatter()
            return "Rate limited. Try again \(formatter.localizedString(for: reset, relativeTo: Date()))"
        case .apiError(let code, let message):
            return "GitHub API error (\(code)): \(message)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}

@MainActor
class GitHubService: PipelineService {
    private let baseURL = "https://api.github.com"
    private let keychainService: KeychainService
    private let urlSession: URLSession

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    init(keychainService: KeychainService? = nil) {
        self.keychainService = keychainService ?? KeychainService.shared

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.urlSession = URLSession(configuration: config)
    }

    // MARK: - Authentication

    func testConnection() async throws -> (user: GitHubUser, repoCount: Int) {
        let user: GitHubUser = try await request(endpoint: "/user")
        let repos = try await fetchAccessibleRepos()
        return (user, repos.count)
    }

    // MARK: - Repository Discovery

    func fetchAccessibleRepos() async throws -> [GitHubRepository] {
        var allRepos: [GitHubRepository] = []
        var page = 1
        let perPage = 100

        while true {
            let repos: [GitHubRepository] = try await request(
                endpoint: "/user/repos",
                queryItems: [
                    URLQueryItem(name: "affiliation", value: "owner,collaborator,organization_member"),
                    URLQueryItem(name: "per_page", value: "\(perPage)"),
                    URLQueryItem(name: "page", value: "\(page)"),
                    URLQueryItem(name: "sort", value: "pushed")
                ]
            )

            allRepos.append(contentsOf: repos)

            if repos.count < perPage {
                break
            }
            page += 1

            // Safety limit
            if page > 10 {
                break
            }
        }

        // Filter to repos where user has admin access or is part of a team
        return allRepos.filter { repo in
            repo.permissions?.admin == true || repo.permissions?.push == true
        }
    }

    // MARK: - Workflow Discovery

    func fetchWorkflows(for repoFullName: String) async throws -> [GitHubWorkflow] {
        let response: GitHubWorkflowsResponse = try await request(
            endpoint: "/repos/\(repoFullName)/actions/workflows"
        )
        return response.workflows.filter { $0.state == "active" }
    }

    // MARK: - Workflow Runs

    func fetchLatestRuns(for repoFullName: String, workflowId: Int? = nil, branch: String? = nil) async throws -> [GitHubWorkflowRun] {
        var queryItems = [
            URLQueryItem(name: "per_page", value: "10")
        ]

        if let branch = branch {
            queryItems.append(URLQueryItem(name: "branch", value: branch))
        }

        let endpoint: String
        if let workflowId = workflowId {
            endpoint = "/repos/\(repoFullName)/actions/workflows/\(workflowId)/runs"
        } else {
            endpoint = "/repos/\(repoFullName)/actions/runs"
        }

        let response: GitHubRunsResponse = try await request(endpoint: endpoint, queryItems: queryItems)
        return response.workflowRuns
    }

    // MARK: - PipelineService Protocol

    func fetchPipelines() async throws -> [Pipeline] {
        let settings = AppSettings.shared
        let monitoredWorkflows = settings.monitoredWorkflows.filter { $0.isEnabled }

        guard !monitoredWorkflows.isEmpty else {
            return []
        }

        var pipelines: [Pipeline] = []

        for workflow in monitoredWorkflows {
            do {
                let runs = try await fetchLatestRuns(
                    for: workflow.repoFullName,
                    workflowId: workflow.workflowId,
                    branch: workflow.branchFilter
                )

                // Take only the most recent run per workflow
                if let latestRun = runs.first {
                    let status: PipelineStatus
                    if latestRun.isFailed {
                        status = .failed
                    } else if latestRun.isRunning {
                        status = .running
                    } else if latestRun.isSuccess {
                        status = .success
                    } else {
                        status = .pending
                    }

                    let pipeline = Pipeline(
                        name: workflow.workflowName,
                        repository: workflow.repoFullName,
                        status: status,
                        lastRun: latestRun.updatedAt,
                        duration: "",
                        htmlUrl: latestRun.htmlUrl,
                        workflowId: workflow.workflowId,
                        runId: latestRun.id
                    )
                    pipelines.append(pipeline)
                }
            } catch {
                // Log error but continue with other workflows
                print("Failed to fetch runs for \(workflow.workflowName): \(error)")
            }
        }

        return pipelines
    }

    // MARK: - Private Helpers

    private func request<T: Decodable>(endpoint: String, queryItems: [URLQueryItem] = []) async throws -> T {
        guard let token = keychainService.getToken() else {
            throw GitHubError.noToken
        }

        var components = URLComponents(string: baseURL + endpoint)!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw GitHubError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubError.networkError(URLError(.badServerResponse))
        }

        // Check for rate limiting
        if httpResponse.statusCode == 403,
           let resetTimestamp = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Reset"),
           let resetTime = Double(resetTimestamp) {
            throw GitHubError.rateLimited(resetDate: Date(timeIntervalSince1970: resetTime))
        }

        // Check for auth errors
        if httpResponse.statusCode == 401 {
            throw GitHubError.invalidToken
        }

        // Check for other errors
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GitHubError.apiError(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw GitHubError.decodingError(error)
        }
    }
}
