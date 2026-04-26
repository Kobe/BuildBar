//
//  ContentView.swift
//  BuildBar
//
//  Menubar dropdown showing CI status
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pipelineStore: PipelineStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            pipelineList

            Divider()
                .padding(.vertical, 8)

            menuItems
        }
        .padding()
        .fixedSize()
    }

    // MARK: - Pipeline List

    private var pipelineList: some View {
        let failedPipelines = pipelineStore.pipelines.filter { $0.status == .failed }
        let groupedByRepo = Dictionary(grouping: failedPipelines) { $0.repository }
        let sortedRepos = groupedByRepo.keys.sorted()

        return VStack(alignment: .leading, spacing: 0) {
            if let message = pipelineStore.errorMessage {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundColor(.buildBarRed)
                    .padding(.vertical, 8)
            } else if pipelineStore.isRefreshing && pipelineStore.pipelines.isEmpty {
                Text("Loading pipelines...")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else if failedPipelines.isEmpty {
                Text("All pipelines passing")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                Text("FAILING RUNS")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)

                ForEach(Array(sortedRepos.enumerated()), id: \.element) { repoIndex, repo in
                    let pipelines = groupedByRepo[repo] ?? []

                    ForEach(Array(pipelines.enumerated()), id: \.element.id) { index, pipeline in
                        PipelineRowView(pipeline: pipeline, showRepo: true)

                        if !(repoIndex == sortedRepos.count - 1 && index == pipelines.count - 1) {
                            Divider()
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Last Refresh

    @ViewBuilder
    private var lastRefreshView: some View {
        if pipelineStore.isRefreshing {
            HStack(spacing: 4) {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 12, height: 12)
                Text("Checking...")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        } else if let lastRefresh = pipelineStore.lastRefresh {
            Button {
                Task { await pipelineStore.refresh() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                    Text("Last checked \(formatDate(lastRefresh))")
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Menu Items

    private var menuItems: some View {
        VStack(alignment: .leading, spacing: 4) {
            lastRefreshView

            Divider()

            Button("Preferences...") {
                openWindow(id: "preferences")
            }
            .buttonStyle(.plain)
            .keyboardShortcut(",", modifiers: .command)

            Divider()
                .padding(.vertical, 4)

            Button("Quit BuildBar") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}

struct PipelineRowView: View {
    let pipeline: Pipeline
    var showRepo: Bool = true

    var body: some View {
        Button {
            if let urlString = pipeline.htmlUrl, let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        } label: {
            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(pipeline.status.color)
                    .frame(width: 8, height: 8)
                    .padding(.top, 5)

                (Text(pipeline.name)
                    .font(.system(size: 13, weight: .medium)) +
                Text("\n\(pipeline.repository)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary))
                .fixedSize(horizontal: true, vertical: false)

                Spacer()

                Text(formatDate(pipeline.lastRun))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ContentView()
        .environmentObject(PipelineStore())
}
