//
//  SettingsViewModel.swift
//  BuildBar
//
//  Handles GitHub connection testing and settings state
//

import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var tokenInput: String = ""
    @Published var isTestingConnection: Bool = false
    @Published var connectionStatus: ConnectionStatus = .notConnected
    @Published var errorMessage: String?

    private let keychainService: KeychainService
    private let gitHubService: GitHubService

    enum ConnectionStatus: Equatable {
        case notConnected
        case testing
        case connected(username: String, repoCount: Int)
        case failed(message: String)

        var isConnected: Bool {
            if case .connected = self { return true }
            return false
        }
    }

    init(keychainService: KeychainService? = nil) {
        let keychain = keychainService ?? KeychainService.shared
        self.keychainService = keychain
        self.gitHubService = GitHubService(keychainService: keychain)

        // Load existing token (masked)
        if keychain.hasToken {
            tokenInput = "ghp_••••••••••••••••••••"
            // Auto-test on load
            Task {
                await testConnection()
            }
        }
    }

    var hasExistingToken: Bool {
        keychainService.hasToken
    }

    func saveAndTestToken() async {
        guard !tokenInput.isEmpty else { return }

        // Don't save if it's the masked placeholder
        if tokenInput.hasPrefix("ghp_••") && hasExistingToken {
            await testConnection()
            return
        }

        do {
            try keychainService.saveToken(tokenInput)
            await testConnection()
        } catch {
            errorMessage = error.localizedDescription
            connectionStatus = .failed(message: error.localizedDescription)
        }
    }

    func testConnection() async {
        isTestingConnection = true
        connectionStatus = .testing
        errorMessage = nil

        do {
            let result = try await gitHubService.testConnection()
            connectionStatus = .connected(username: result.user.login, repoCount: result.repoCount)
        } catch {
            connectionStatus = .failed(message: error.localizedDescription)
            errorMessage = error.localizedDescription
        }

        isTestingConnection = false
    }

    func clearToken() {
        do {
            try keychainService.deleteToken()
            tokenInput = ""
            connectionStatus = .notConnected
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
