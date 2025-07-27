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
    
    var icon: String {
        switch self {
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
}

struct Pipeline: Identifiable {
    let id = UUID()
    let name: String
    let repository: String
    let status: PipelineStatus
    let lastRun: Date
    let duration: String
}

class PipelineStore: ObservableObject {
    @Published var pipelines: [Pipeline] = [
        Pipeline(
            name: "Main Build",
            repository: "user/awesome-app",
            status: .success,
            lastRun: Date().addingTimeInterval(-3600),
            duration: "2m 34s"
        ),
        Pipeline(
            name: "Test Suite",
            repository: "user/awesome-app",
            status: .failed,
            lastRun: Date().addingTimeInterval(-1800),
            duration: "1m 12s"
        ),
        Pipeline(
            name: "Deploy Staging",
            repository: "user/web-service",
            status: .running,
            lastRun: Date().addingTimeInterval(-300),
            duration: "3m 45s"
        ),
        Pipeline(
            name: "Security Scan",
            repository: "user/web-service",
            status: .pending,
            lastRun: Date().addingTimeInterval(-7200),
            duration: "4m 22s"
        ),
        Pipeline(
            name: "Docker Build",
            repository: "user/microservice",
            status: .success,
            lastRun: Date().addingTimeInterval(-5400),
            duration: "1m 58s"
        )
    ]
    
    var overallStatus: PipelineStatus {
        if pipelines.contains(where: { $0.status == .failed }) {
            return .failed
        } else if pipelines.contains(where: { $0.status == .running }) {
            return .running
        } else if pipelines.contains(where: { $0.status == .pending }) {
            return .pending
        } else {
            return .success
        }
    }
}