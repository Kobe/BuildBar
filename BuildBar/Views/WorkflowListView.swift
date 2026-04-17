//
//  WorkflowListView.swift
//  BuildBar
//
//  Right column of Run Config: workflow checkboxes
//

import SwiftUI

struct WorkflowListView: View {
    @ObservedObject var viewModel: RunConfigViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let repo = viewModel.selectedRepo {
                headerView(repo: repo)

                Divider()

                if viewModel.isLoadingWorkflows {
                    loadingView
                } else if viewModel.workflows.isEmpty {
                    emptyView
                } else {
                    workflowList
                }
            } else {
                placeholderView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func headerView(repo: GitHubRepository) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(repo.fullName)
                .font(.title2)
                .fontWeight(.semibold)

            Text("Select workflows to monitor")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading workflows...")
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No workflows found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("This repository has no GitHub Actions workflows.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "arrow.left")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("Select a repository")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var workflowList: some View {
        List {
            ForEach(viewModel.workflows) { workflow in
                WorkflowRowView(
                    workflow: workflow,
                    isEnabled: viewModel.isWorkflowEnabled(workflow),
                    status: viewModel.workflowStatuses[workflow.id] ?? .pending,
                    monitoredWorkflow: viewModel.getMonitoredWorkflow(for: workflow),
                    onToggle: {
                        viewModel.toggleWorkflow(workflow)
                    }
                )
            }
        }
        .listStyle(.plain)
    }
}

struct WorkflowRowView: View {
    let workflow: GitHubWorkflow
    let isEnabled: Bool
    let status: PipelineStatus
    let monitoredWorkflow: MonitoredWorkflow?
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.checkbox)
            .labelsHidden()

            Circle()
                .fill(status.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(workflow.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text("branch: \(monitoredWorkflow?.branchDisplayText ?? "all")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(statusText)
                .font(.subheadline)
                .foregroundColor(status.color)
        }
        .padding(.vertical, 4)
    }

    private var statusText: String {
        switch status {
        case .success: return "Passing"
        case .failed: return "Failing"
        case .running: return "Running"
        case .pending: return "Pending"
        }
    }
}
