//
//  MonitoredWorkflow.swift
//  BuildBar
//
//  Represents a workflow that the user has selected to monitor
//

import Foundation

struct MonitoredWorkflow: Codable, Identifiable, Hashable {
    let repoFullName: String
    let workflowId: Int
    let workflowName: String
    var branchFilter: String?
    var isEnabled: Bool

    var id: String { "\(repoFullName)/\(workflowId)" }

    var branchDisplayText: String {
        branchFilter ?? "all branches"
    }
}
