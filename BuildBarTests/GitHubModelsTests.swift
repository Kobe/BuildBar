//
//  GitHubModelsTests.swift
//  BuildBarTests
//

import XCTest
@testable import BuildBar

final class GitHubModelsTests: XCTestCase {

    // MARK: - GitHubWorkflowRun Status Tests

    func testWorkflowRunIsFailed() {
        let failedRun = makeRun(status: "completed", conclusion: "failure")
        XCTAssertTrue(failedRun.isFailed)
        XCTAssertFalse(failedRun.isSuccess)
        XCTAssertFalse(failedRun.isRunning)

        let cancelledRun = makeRun(status: "completed", conclusion: "cancelled")
        XCTAssertTrue(cancelledRun.isFailed)
    }

    func testWorkflowRunIsSuccess() {
        let successRun = makeRun(status: "completed", conclusion: "success")
        XCTAssertTrue(successRun.isSuccess)
        XCTAssertFalse(successRun.isFailed)
        XCTAssertFalse(successRun.isRunning)
    }

    func testWorkflowRunIsRunning() {
        let inProgressRun = makeRun(status: "in_progress", conclusion: nil)
        XCTAssertTrue(inProgressRun.isRunning)
        XCTAssertFalse(inProgressRun.isFailed)
        XCTAssertFalse(inProgressRun.isSuccess)

        let queuedRun = makeRun(status: "queued", conclusion: nil)
        XCTAssertTrue(queuedRun.isRunning)
    }

    func testWorkflowRunSkippedIsNotFailed() {
        let skippedRun = makeRun(status: "completed", conclusion: "skipped")
        XCTAssertFalse(skippedRun.isFailed)
        XCTAssertFalse(skippedRun.isSuccess)
    }

    // MARK: - JSON Decoding Tests

    func testDecodeGitHubUser() throws {
        let json = """
        {"login": "octocat", "id": 12345}
        """
        let user = try JSONDecoder().decode(GitHubUser.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(user.login, "octocat")
        XCTAssertEqual(user.id, 12345)
    }

    func testDecodeGitHubRepository() throws {
        let json = """
        {
            "id": 123,
            "full_name": "acme/web",
            "name": "web",
            "owner": {"login": "acme"},
            "permissions": {"admin": true, "push": true, "pull": true}
        }
        """
        let repo = try JSONDecoder().decode(GitHubRepository.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(repo.id, 123)
        XCTAssertEqual(repo.fullName, "acme/web")
        XCTAssertEqual(repo.name, "web")
        XCTAssertEqual(repo.owner.login, "acme")
        XCTAssertEqual(repo.permissions?.admin, true)
    }

    func testDecodeGitHubWorkflow() throws {
        let json = """
        {"id": 456, "name": "CI", "path": ".github/workflows/ci.yml", "state": "active"}
        """
        let workflow = try JSONDecoder().decode(GitHubWorkflow.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(workflow.id, 456)
        XCTAssertEqual(workflow.name, "CI")
        XCTAssertEqual(workflow.path, ".github/workflows/ci.yml")
        XCTAssertEqual(workflow.state, "active")
    }

    // MARK: - Helper

    private func makeRun(status: String, conclusion: String?) -> GitHubWorkflowRun {
        GitHubWorkflowRun(
            id: 1,
            name: "Test",
            workflowId: 1,
            headBranch: "main",
            status: status,
            conclusion: conclusion,
            createdAt: Date(),
            updatedAt: Date(),
            htmlUrl: "https://github.com"
        )
    }
}
