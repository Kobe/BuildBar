//
//  PipelineStatusTests.swift
//  BuildBarTests
//

import XCTest
@testable import BuildBar

final class PipelineStatusTests: XCTestCase {

    // MARK: - Color

    func testSuccessColor() {
        XCTAssertEqual(PipelineStatus.success.color, .green)
    }

    func testFailedColor() {
        XCTAssertEqual(PipelineStatus.failed.color, .red)
    }

    func testRunningColor() {
        XCTAssertEqual(PipelineStatus.running.color, .blue)
    }

    func testPendingColor() {
        XCTAssertEqual(PipelineStatus.pending.color, .orange)
    }

    // MARK: - Icon

    func testSuccessIcon() {
        XCTAssertEqual(PipelineStatus.success.icon, "checkmark.circle.fill")
    }

    func testFailedIcon() {
        XCTAssertEqual(PipelineStatus.failed.icon, "xmark.circle.fill")
    }

    func testRunningIcon() {
        XCTAssertEqual(PipelineStatus.running.icon, "arrow.triangle.2.circlepath.circle.fill")
    }

    func testPendingIcon() {
        XCTAssertEqual(PipelineStatus.pending.icon, "clock.circle.fill")
    }

    // MARK: - RawValue

    func testRawValues() {
        XCTAssertEqual(PipelineStatus.success.rawValue, "success")
        XCTAssertEqual(PipelineStatus.failed.rawValue, "failed")
        XCTAssertEqual(PipelineStatus.running.rawValue, "running")
        XCTAssertEqual(PipelineStatus.pending.rawValue, "pending")
    }

    func testAllCasesCount() {
        XCTAssertEqual(PipelineStatus.allCases.count, 4)
    }
}
