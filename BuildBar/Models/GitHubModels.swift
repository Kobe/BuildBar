//
//  GitHubModels.swift
//  BuildBar
//
//  GitHub REST API response models
//

import Foundation

struct GitHubUser: Codable {
    let login: String
    let id: Int
}

struct GitHubRepository: Codable, Identifiable {
    let id: Int
    let fullName: String
    let name: String
    let owner: GitHubOwner
    let permissions: GitHubPermissions?

    enum CodingKeys: String, CodingKey {
        case id, name, owner, permissions
        case fullName = "full_name"
    }
}

struct GitHubOwner: Codable {
    let login: String
}

struct GitHubPermissions: Codable {
    let admin: Bool
    let push: Bool
    let pull: Bool
}

struct GitHubWorkflow: Codable, Identifiable {
    let id: Int
    let name: String
    let path: String
    let state: String
}

struct GitHubWorkflowsResponse: Codable {
    let totalCount: Int
    let workflows: [GitHubWorkflow]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case workflows
    }
}

struct GitHubWorkflowRun: Codable, Identifiable {
    let id: Int
    let name: String?
    let workflowId: Int
    let headBranch: String?
    let status: String
    let conclusion: String?
    let createdAt: Date
    let updatedAt: Date
    let htmlUrl: String

    enum CodingKeys: String, CodingKey {
        case id, name, status, conclusion
        case workflowId = "workflow_id"
        case headBranch = "head_branch"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case htmlUrl = "html_url"
    }

    var isFailed: Bool {
        conclusion == "failure" || conclusion == "cancelled"
    }

    var isSuccess: Bool {
        conclusion == "success"
    }

    var isRunning: Bool {
        status == "in_progress" || status == "queued"
    }
}

struct GitHubRunsResponse: Codable {
    let totalCount: Int
    let workflowRuns: [GitHubWorkflowRun]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case workflowRuns = "workflow_runs"
    }
}
