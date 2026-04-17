//
//  PipelineTests.swift
//  BuildBarTests
//

import XCTest
@testable import BuildBar

final class PipelineTests: XCTestCase {

    func testPipelineInitialization() {
        let date = Date()
        let pipeline = Pipeline(
            name: "Build",
            repository: "acme/web",
            status: .success,
            lastRun: date,
            duration: "2m 30s",
            htmlUrl: "https://github.com/acme/web/actions/runs/123",
            workflowId: 456,
            runId: 789
        )

        XCTAssertEqual(pipeline.name, "Build")
        XCTAssertEqual(pipeline.repository, "acme/web")
        XCTAssertEqual(pipeline.status, .success)
        XCTAssertEqual(pipeline.lastRun, date)
        XCTAssertEqual(pipeline.duration, "2m 30s")
        XCTAssertEqual(pipeline.htmlUrl, "https://github.com/acme/web/actions/runs/123")
        XCTAssertEqual(pipeline.workflowId, 456)
        XCTAssertEqual(pipeline.runId, 789)
    }

    func testPipelineWithOptionalFieldsNil() {
        let pipeline = Pipeline(
            name: "Test",
            repository: "test/repo",
            status: .failed,
            lastRun: Date(),
            duration: "1m"
        )

        XCTAssertNil(pipeline.htmlUrl)
        XCTAssertNil(pipeline.workflowId)
        XCTAssertNil(pipeline.runId)
    }

    func testPipelineHasUniqueId() {
        let pipeline1 = Pipeline(
            name: "Build",
            repository: "acme/web",
            status: .success,
            lastRun: Date(),
            duration: "1m"
        )
        let pipeline2 = Pipeline(
            name: "Build",
            repository: "acme/web",
            status: .success,
            lastRun: Date(),
            duration: "1m"
        )

        XCTAssertNotEqual(pipeline1.id, pipeline2.id)
    }

    func testPipelineIsIdentifiable() {
        let pipeline = Pipeline(
            name: "Build",
            repository: "acme/web",
            status: .success,
            lastRun: Date(),
            duration: "1m"
        )

        // Identifiable protocol requires id property
        XCTAssertNotNil(pipeline.id)
    }
}
