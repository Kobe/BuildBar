//
//  PreferencesView.swift
//  BuildBar
//
//  Combined settings and workflow configuration
//

import SwiftUI

struct PreferencesView: View {
    var body: some View {
        TabView {
            WorkflowsTab()
                .tabItem {
                    Label("Workflows", systemImage: "list.bullet")
                }

            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .frame(width: 700, height: 500)
    }
}

// MARK: - Workflows Tab

struct WorkflowsTab: View {
    @StateObject private var viewModel = RunConfigViewModel()

    var body: some View {
        NavigationSplitView {
            RepoListView(viewModel: viewModel)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
        } detail: {
            WorkflowListView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadRepositories()
        }
    }
}

// MARK: - Settings Tab

struct SettingsTab: View {
    @StateObject private var viewModel = SettingsViewModel()
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
        Form {
            gitHubSection
            pollingSection
            notificationsSection
        }
        .formStyle(.grouped)
    }

    // MARK: - GitHub Section

    private var gitHubSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Personal Access Token")
                    .font(.headline)

                Text("Used to read workflow runs. Stored locally in Keychain.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    SecureField("ghp_...", text: $viewModel.tokenInput)
                        .textFieldStyle(.roundedBorder)

                    Button("Test connection") {
                        Task {
                            await viewModel.saveAndTestToken()
                        }
                    }
                    .disabled(viewModel.tokenInput.isEmpty || viewModel.isTestingConnection)
                }

                connectionStatusView
            }
            .padding(.vertical, 4)
        } header: {
            Text("GitHub")
        }
    }

    @ViewBuilder
    private var connectionStatusView: some View {
        HStack(spacing: 6) {
            switch viewModel.connectionStatus {
            case .notConnected:
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
                Text("Not connected")
                    .foregroundColor(.secondary)

            case .testing:
                ProgressView()
                    .scaleEffect(0.7)
                Text("Testing connection...")
                    .foregroundColor(.secondary)

            case .connected(let username, let repoCount):
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.buildBarGreen)
                Text("Connected as @\(username) · \(repoCount) repos accessible")
                    .foregroundColor(.primary)

            case .failed(let message):
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.buildBarRed)
                Text(message)
                    .foregroundColor(.buildBarRed)
                    .lineLimit(2)
            }

            Spacer()

            if viewModel.hasExistingToken && viewModel.connectionStatus != .testing {
                Button("Clear") {
                    viewModel.clearToken()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.buildBarRed)
            }
        }
        .font(.subheadline)
    }

    // MARK: - Polling Section

    private var pollingSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Check interval")
                    .font(.headline)

                Text("How often to poll GitHub for new runs.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("", selection: $settings.pollingInterval) {
                    ForEach(PollingInterval.allCases, id: \.self) { interval in
                        Text(interval.displayName).tag(interval)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            .padding(.vertical, 4)
        } header: {
            Text("Polling")
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                Toggle(isOn: $settings.playSoundOnFailure) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Play sound on failure")
                        Text(settings.failureSoundName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)

                Divider()

                Toggle(isOn: $settings.animateMenubarIcon) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Animate menubar icon")
                        Text("Blinks when there are failures")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)

                Divider()

                Toggle(isOn: $settings.showSystemNotification) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show system notification")
                        Text("Native macOS notification")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
        } header: {
            Text("Notifications")
        }
    }
}

#Preview {
    PreferencesView()
}
