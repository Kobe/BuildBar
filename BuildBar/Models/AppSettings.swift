//
//  AppSettings.swift
//  BuildBar
//
//  User preferences stored in UserDefaults
//

import SwiftUI
import Combine

enum PollingInterval: Int, CaseIterable, Codable {
    case thirtySeconds = 30
    case oneMinute = 60
    case fiveMinutes = 300
    case fifteenMinutes = 900

    var displayName: String {
        switch self {
        case .thirtySeconds: return "30s"
        case .oneMinute: return "1m"
        case .fiveMinutes: return "5m"
        case .fifteenMinutes: return "15m"
        }
    }

    var timeInterval: TimeInterval {
        TimeInterval(rawValue)
    }
}

@MainActor
class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("pollingInterval") var pollingIntervalRaw: Int = PollingInterval.oneMinute.rawValue
    @AppStorage("playSoundOnFailure") var playSoundOnFailure: Bool = true
    @AppStorage("failureSoundName") var failureSoundName: String = "Glass"
    @AppStorage("animateMenubarIcon") var animateMenubarIcon: Bool = true
    @AppStorage("showSystemNotification") var showSystemNotification: Bool = false
    @AppStorage("monitoredWorkflowsData") private var monitoredWorkflowsData: Data = Data()

    var pollingInterval: PollingInterval {
        get { PollingInterval(rawValue: pollingIntervalRaw) ?? .oneMinute }
        set { pollingIntervalRaw = newValue.rawValue }
    }

    var monitoredWorkflows: [MonitoredWorkflow] {
        get {
            guard !monitoredWorkflowsData.isEmpty else { return [] }
            return (try? JSONDecoder().decode([MonitoredWorkflow].self, from: monitoredWorkflowsData)) ?? []
        }
        set {
            monitoredWorkflowsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    func addMonitoredWorkflow(_ workflow: MonitoredWorkflow) {
        var workflows = monitoredWorkflows
        if !workflows.contains(where: { $0.id == workflow.id }) {
            workflows.append(workflow)
            monitoredWorkflows = workflows
        }
    }

    func removeMonitoredWorkflow(_ workflow: MonitoredWorkflow) {
        var workflows = monitoredWorkflows
        workflows.removeAll { $0.id == workflow.id }
        monitoredWorkflows = workflows
    }

    func updateMonitoredWorkflow(_ workflow: MonitoredWorkflow) {
        var workflows = monitoredWorkflows
        if let index = workflows.firstIndex(where: { $0.id == workflow.id }) {
            workflows[index] = workflow
            monitoredWorkflows = workflows
        }
    }

    func isWorkflowMonitored(repoFullName: String, workflowId: Int) -> Bool {
        monitoredWorkflows.contains { $0.repoFullName == repoFullName && $0.workflowId == workflowId && $0.isEnabled }
    }

    func seedTestWorkflows() {
        guard monitoredWorkflows.isEmpty else { return }

        let testWorkflows = [
            MonitoredWorkflow(
                repoFullName: "Kobe/fizz-buzz-service",
                workflowId: 9315924,
                workflowName: "verify_main_branch",
                branchFilter: nil,
                isEnabled: true
            ),
            MonitoredWorkflow(
                repoFullName: "Kobe/fizz-buzz-service",
                workflowId: 9315737,
                workflowName: "verify_pull_request",
                branchFilter: nil,
                isEnabled: true
            )
        ]

        for workflow in testWorkflows {
            addMonitoredWorkflow(workflow)
        }
    }
}
