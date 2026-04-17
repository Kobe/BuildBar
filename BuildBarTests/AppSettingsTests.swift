//
//  AppSettingsTests.swift
//  BuildBarTests
//

import XCTest
@testable import BuildBar

@MainActor
final class AppSettingsTests: XCTestCase {

    // MARK: - PollingInterval Tests

    func testPollingIntervalDisplayNames() {
        XCTAssertEqual(PollingInterval.thirtySeconds.displayName, "30s")
        XCTAssertEqual(PollingInterval.oneMinute.displayName, "1m")
        XCTAssertEqual(PollingInterval.fiveMinutes.displayName, "5m")
        XCTAssertEqual(PollingInterval.fifteenMinutes.displayName, "15m")
    }

    func testPollingIntervalTimeIntervals() {
        XCTAssertEqual(PollingInterval.thirtySeconds.timeInterval, 30)
        XCTAssertEqual(PollingInterval.oneMinute.timeInterval, 60)
        XCTAssertEqual(PollingInterval.fiveMinutes.timeInterval, 300)
        XCTAssertEqual(PollingInterval.fifteenMinutes.timeInterval, 900)
    }

    func testPollingIntervalRawValues() {
        XCTAssertEqual(PollingInterval.thirtySeconds.rawValue, 30)
        XCTAssertEqual(PollingInterval.oneMinute.rawValue, 60)
        XCTAssertEqual(PollingInterval.fiveMinutes.rawValue, 300)
        XCTAssertEqual(PollingInterval.fifteenMinutes.rawValue, 900)
    }

    func testPollingIntervalAllCases() {
        XCTAssertEqual(PollingInterval.allCases.count, 4)
    }

    // MARK: - MonitoredWorkflow Tests

    func testMonitoredWorkflowId() {
        let workflow = MonitoredWorkflow(
            repoFullName: "acme/web",
            workflowId: 123,
            workflowName: "Build",
            branchFilter: "main",
            isEnabled: true
        )
        XCTAssertEqual(workflow.id, "acme/web/123")
    }

    func testMonitoredWorkflowBranchDisplayText() {
        let withBranch = MonitoredWorkflow(
            repoFullName: "acme/web",
            workflowId: 123,
            workflowName: "Build",
            branchFilter: "main",
            isEnabled: true
        )
        XCTAssertEqual(withBranch.branchDisplayText, "main")

        let withoutBranch = MonitoredWorkflow(
            repoFullName: "acme/web",
            workflowId: 123,
            workflowName: "Build",
            branchFilter: nil,
            isEnabled: true
        )
        XCTAssertEqual(withoutBranch.branchDisplayText, "all branches")
    }

    func testMonitoredWorkflowEquality() {
        let workflow1 = MonitoredWorkflow(
            repoFullName: "acme/web",
            workflowId: 123,
            workflowName: "Build",
            branchFilter: nil,
            isEnabled: true
        )
        let workflow2 = MonitoredWorkflow(
            repoFullName: "acme/web",
            workflowId: 123,
            workflowName: "Build",
            branchFilter: nil,
            isEnabled: true
        )
        XCTAssertEqual(workflow1, workflow2)
    }
}
