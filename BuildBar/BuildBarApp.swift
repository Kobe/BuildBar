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
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(pipelineStore)
        } label: {
            Image(systemName: menuBarIcon)
                .foregroundColor(menuBarColor)
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
            return .green
        case .failed:
            return .red
        case .running:
            return .blue
        case .pending:
            return .orange
        }
    }
}
