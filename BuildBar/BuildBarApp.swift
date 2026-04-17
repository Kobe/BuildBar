//
//  BuildBarApp.swift
//  BuildBar
//
//  Created by Kobe on 7/26/25.
//

import SwiftUI

@main
struct BuildBarApp: App {
    @StateObject private var pipelineStore = PipelineStore()
    @StateObject private var iconAnimator = MenubarIconAnimator()

    var body: some Scene {
        // Menubar dropdown
        MenuBarExtra {
            ContentView()
                .environmentObject(pipelineStore)
        } label: {
            menuBarLabel
        }

        // Preferences window
        Window("BuildBar Preferences", id: "preferences") {
            PreferencesView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        let failedCount = pipelineStore.pipelines.filter { $0.status == .failed }.count

        HStack(spacing: 2) {
            if failedCount > 0 {
                // Show red icon with count when there are failures
                if iconAnimator.isVisible || !AppSettings.shared.animateMenubarIcon {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.buildBarRed)
                }

                Text("\(failedCount)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.buildBarRed)
            } else {
                // Show green checkmark when all passing
                Image(systemName: menuBarIcon)
                    .foregroundColor(menuBarColor)
            }
        }
        .onChange(of: failedCount) { _, newCount in
            iconAnimator.updateFailureCount(newCount)
        }
    }

    private var menuBarIcon: String {
        switch pipelineStore.overallStatus {
        case .success:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        case .running:
            return "arrow.triangle.2.circlepath.circle.fill"
        case .pending:
            return "clock.circle.fill"
        }
    }

    private var menuBarColor: Color {
        switch pipelineStore.overallStatus {
        case .success:
            return .buildBarGreen
        case .failed:
            return .buildBarRed
        case .running:
            return .buildBarBlue
        case .pending:
            return .buildBarOrange
        }
    }
}
