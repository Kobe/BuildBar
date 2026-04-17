//
//  PipelineStatusTests.swift
//  BuildBarTests
//

import XCTest
import SwiftUI
@testable import BuildBar

final class PipelineStatusTests: XCTestCase {

    // MARK: - Color (WCAG 2.2 AA compliant colors)

    func testSuccessColor() {
        XCTAssertEqual(PipelineStatus.success.color, .buildBarGreen)
    }

    func testFailedColor() {
        XCTAssertEqual(PipelineStatus.failed.color, .buildBarRed)
    }

    func testRunningColor() {
        XCTAssertEqual(PipelineStatus.running.color, .buildBarBlue)
    }

    func testPendingColor() {
        XCTAssertEqual(PipelineStatus.pending.color, .buildBarOrange)
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
