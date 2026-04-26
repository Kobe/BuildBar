//
//  PipelineModel.swift
//  BuildBar
//
//  Created by Kobe on 7/27/25.
//

import SwiftUI
import Combine

enum PipelineStatus: String, CaseIterable {
    case success = "success"
    case failed = "failed"
    case running = "running"
    case pending = "pending"

    var color: Color {
        switch self {
        case .success: return .buildBarGreen
        case .failed:  return .buildBarRed
        case .running: return .buildBarBlue
        case .pending: return .buildBarOrange
        }
    }

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .failed:  return "xmark.circle.fill"
        case .running: return "arrow.triangle.2.circlepath.circle.fill"
        case .pending: return "clock.circle.fill"
        }
    }
}

struct Pipeline: Identifiable {
    let id: UUID
    let name: String
    let repository: String
    let status: PipelineStatus
    let lastRun: Date
    let duration: String
    let htmlUrl: String?
    let workflowId: Int?
    let runId: Int?

    init(
        id: UUID = UUID(),
        name: String,
        repository: String,
        status: PipelineStatus,
        lastRun: Date,
        duration: String,
        htmlUrl: String? = nil,
        workflowId: Int? = nil,
        runId: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.repository = repository
        self.status = status
        self.lastRun = lastRun
        self.duration = duration
        self.htmlUrl = htmlUrl
        self.workflowId = workflowId
        self.runId = runId
    }
}

@MainActor
protocol PipelineService {
    func fetchPipelines() async throws -> [Pipeline]
}

class LocalPipelineService: PipelineService {
    func fetchPipelines() async throws -> [Pipeline] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return [
            Pipeline(name: "deploy-prod", repository: "acme/web", status: .failed, lastRun: Date().addingTimeInterval(-120), duration: "2m 34s", htmlUrl: "https://github.com/acme/web/actions/runs/123"),
            Pipeline(name: "e2e-tests", repository: "acme/web", status: .failed, lastRun: Date().addingTimeInterval(-840), duration: "1m 12s", htmlUrl: "https://github.com/acme/web/actions/runs/456"),
            Pipeline(name: "lint-and-build", repository: "acme/api", status: .failed, lastRun: Date().addingTimeInterval(-3600), duration: "3m 45s", htmlUrl: "https://github.com/acme/api/actions/runs/789"),
            Pipeline(name: "nightly", repository: "acme/web", status: .success, lastRun: Date().addingTimeInterval(-7200), duration: "4m 22s", htmlUrl: "https://github.com/acme/web/actions/runs/111"),
            Pipeline(name: "security-scan", repository: "acme/api", status: .success, lastRun: Date().addingTimeInterval(-5400), duration: "1m 58s", htmlUrl: "https://github.com/acme/api/actions/runs/222"),
        ]
    }
}

@MainActor
class PipelineStore: ObservableObject {
    @Published var pipelines: [Pipeline] = []
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var lastRefresh: Date?

    private let service: any PipelineService
    private let notificationService: NotificationService
    private var pollingTimer: Timer?
    private var previousFailedIds: Set<String> = []

    init(service: (any PipelineService)? = nil, notificationService: NotificationService? = nil) {
        self.notificationService = notificationService ?? NotificationService.shared

        // Seed test workflows if none exist
        AppSettings.shared.seedTestWorkflows()

        // Use GitHubService if monitored workflows exist or token exists, otherwise LocalPipelineService for testing
        let workflows = AppSettings.shared.monitoredWorkflows
        if let providedService = service {
            self.service = providedService
        } else if !workflows.isEmpty || KeychainService.shared.hasToken {
            self.service = GitHubService()
        } else {
            self.service = LocalPipelineService()
        }

        startPolling()

        // Load runs immediately on app start
        Task {
            await refresh()
        }
    }

    deinit {
        pollingTimer?.invalidate()
    }

    func refresh() async {
        isRefreshing = true
        errorMessage = nil
        do {
            let newPipelines = try await service.fetchPipelines()
            checkForNewFailures(newPipelines)
            pipelines = newPipelines
            lastRefresh = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
        isRefreshing = false
    }

    var overallStatus: PipelineStatus {
        if pipelines.contains(where: { $0.status == .failed })  { return .failed }
        if pipelines.contains(where: { $0.status == .running }) { return .running }
        if pipelines.contains(where: { $0.status == .pending }) { return .pending }
        return .success
    }

    var failedCount: Int {
        pipelines.filter { $0.status == .failed }.count
    }

    // MARK: - Polling

    func startPolling() {
        stopPolling()

        let interval = AppSettings.shared.pollingInterval.timeInterval
        pollingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refresh()
            }
        }
    }

    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    func updatePollingInterval() {
        startPolling()
    }

    // MARK: - Notifications

    private func checkForNewFailures(_ newPipelines: [Pipeline]) {
        let newFailedPipelines = newPipelines.filter { $0.status == .failed }
        let newFailedIds = Set(newFailedPipelines.map { "\($0.repository)/\($0.name)" })

        // Find pipelines that are newly failed
        let newlyFailed = newFailedPipelines.filter { pipeline in
            let id = "\(pipeline.repository)/\(pipeline.name)"
            return !previousFailedIds.contains(id)
        }

        // Notify for each newly failed pipeline
        for pipeline in newlyFailed {
            notificationService.notifyFailure(
                workflowName: pipeline.name,
                repoName: pipeline.repository,
                url: pipeline.htmlUrl
            )
        }

        previousFailedIds = newFailedIds
    }
}
