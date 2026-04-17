//
//  RunConfigViewModel.swift
//  BuildBar
//
//  Manages repository and workflow selection state
//

import SwiftUI
import Combine

@MainActor
class RunConfigViewModel: ObservableObject {
    @Published var repositories: [GitHubRepository] = []
    @Published var selectedRepo: GitHubRepository?
    @Published var workflows: [GitHubWorkflow] = []
    @Published var workflowStatuses: [Int: PipelineStatus] = [:]
    @Published var isLoadingRepos: Bool = false
    @Published var isLoadingWorkflows: Bool = false
    @Published var errorMessage: String?

    private let gitHubService: GitHubService
    private let settings: AppSettings

    init(gitHubService: GitHubService? = nil, settings: AppSettings? = nil) {
        self.gitHubService = gitHubService ?? GitHubService()
        self.settings = settings ?? AppSettings.shared
    }

    func loadRepositories() async {
        isLoadingRepos = true
        errorMessage = nil

        do {
            repositories = try await gitHubService.fetchAccessibleRepos()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingRepos = false
    }

    func selectRepository(_ repo: GitHubRepository) async {
        selectedRepo = repo
        workflows = []
        workflowStatuses = [:]
        isLoadingWorkflows = true
        errorMessage = nil

        do {
            workflows = try await gitHubService.fetchWorkflows(for: repo.fullName)

            // Fetch latest run status for each workflow
            for workflow in workflows {
                do {
                    let runs = try await gitHubService.fetchLatestRuns(
                        for: repo.fullName,
                        workflowId: workflow.id
                    )
                    if let latestRun = runs.first {
                        if latestRun.isFailed {
                            workflowStatuses[workflow.id] = .failed
                        } else if latestRun.isRunning {
                            workflowStatuses[workflow.id] = .running
                        } else if latestRun.isSuccess {
                            workflowStatuses[workflow.id] = .success
                        } else {
                            workflowStatuses[workflow.id] = .pending
                        }
                    }
                } catch {
                    // Ignore individual workflow errors
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingWorkflows = false
    }

    func isWorkflowEnabled(_ workflow: GitHubWorkflow) -> Bool {
        guard let repo = selectedRepo else { return false }
        return settings.isWorkflowMonitored(repoFullName: repo.fullName, workflowId: workflow.id)
    }

    func toggleWorkflow(_ workflow: GitHubWorkflow) {
        guard let repo = selectedRepo else { return }

        let existingWorkflow = settings.monitoredWorkflows.first {
            $0.repoFullName == repo.fullName && $0.workflowId == workflow.id
        }

        if let existing = existingWorkflow {
            var updated = existing
            updated.isEnabled.toggle()
            settings.updateMonitoredWorkflow(updated)
        } else {
            let monitored = MonitoredWorkflow(
                repoFullName: repo.fullName,
                workflowId: workflow.id,
                workflowName: workflow.name,
                branchFilter: nil,
                isEnabled: true
            )
            settings.addMonitoredWorkflow(monitored)
        }

        objectWillChange.send()
    }

    func getMonitoredWorkflow(for workflow: GitHubWorkflow) -> MonitoredWorkflow? {
        guard let repo = selectedRepo else { return nil }
        return settings.monitoredWorkflows.first {
            $0.repoFullName == repo.fullName && $0.workflowId == workflow.id
        }
    }

    func aggregateStatus(for repo: GitHubRepository) -> PipelineStatus {
        let repoWorkflows = settings.monitoredWorkflows.filter {
            $0.repoFullName == repo.fullName && $0.isEnabled
        }

        guard !repoWorkflows.isEmpty else {
            return .success
        }

        // This is a simplified version - in reality we'd need to track actual run statuses
        // For now, return success as default
        return .success
    }
}
