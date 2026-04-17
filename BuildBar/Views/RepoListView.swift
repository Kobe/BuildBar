//
//  RepoListView.swift
//  BuildBar
//
//  Left column of Run Config: repository list
//

import SwiftUI

struct RepoListView: View {
    @ObservedObject var viewModel: RunConfigViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isLoadingRepos {
                loadingView
            } else if let error = viewModel.errorMessage, viewModel.repositories.isEmpty {
                errorView(error)
            } else {
                repoList
            }
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading repositories...")
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.buildBarOrange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry") {
                Task {
                    await viewModel.loadRepositories()
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var repoList: some View {
        List(selection: Binding(
            get: { viewModel.selectedRepo?.id },
            set: { id in
                if let repo = viewModel.repositories.first(where: { $0.id == id }) {
                    Task {
                        await viewModel.selectRepository(repo)
                    }
                }
            }
        )) {
            Section {
                ForEach(viewModel.repositories) { repo in
                    RepoRowView(repo: repo, status: viewModel.aggregateStatus(for: repo))
                        .tag(repo.id)
                }
            } header: {
                Text("REPOSITORIES")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(.sidebar)
    }
}

struct RepoRowView: View {
    let repo: GitHubRepository
    let status: PipelineStatus

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)

            Text(repo.fullName)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}
