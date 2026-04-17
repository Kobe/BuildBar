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
        case .success: return .green
        case .failed:  return .red
        case .running: return .blue
        case .pending: return .orange
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

    init(id: UUID = UUID(), name: String, repository: String, status: PipelineStatus, lastRun: Date, duration: String) {
        self.id = id
        self.name = name
        self.repository = repository
        self.status = status
        self.lastRun = lastRun
        self.duration = duration
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
            Pipeline(name: "Main Build",     repository: "user/awesome-app",  status: .success, lastRun: Date().addingTimeInterval(-3600), duration: "2m 34s"),
            Pipeline(name: "Test Suite",     repository: "user/awesome-app",  status: .failed,  lastRun: Date().addingTimeInterval(-1800), duration: "1m 12s"),
            Pipeline(name: "Deploy Staging", repository: "user/web-service",  status: .running, lastRun: Date().addingTimeInterval(-300),  duration: "3m 45s"),
            Pipeline(name: "Security Scan",  repository: "user/web-service",  status: .pending, lastRun: Date().addingTimeInterval(-7200), duration: "4m 22s"),
            Pipeline(name: "Docker Build",   repository: "user/microservice", status: .success, lastRun: Date().addingTimeInterval(-5400), duration: "1m 58s"),
        ]
    }
}

@MainActor
class PipelineStore: ObservableObject {
    @Published var pipelines: [Pipeline] = []
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    private let service: any PipelineService

    init(service: (any PipelineService)? = nil) {
        self.service = service ?? LocalPipelineService()
    }

    func refresh() async {
        isRefreshing = true
        errorMessage = nil
        do {
            pipelines = try await service.fetchPipelines()
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
}
