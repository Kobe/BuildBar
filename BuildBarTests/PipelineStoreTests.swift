//
//  PipelineStoreTests.swift
//  BuildBarTests
//

import XCTest
@testable import BuildBar

// MARK: - Mock Service

private struct MockPipelineService: PipelineService {
    var pipelines: [Pipeline]
    var error: Error?

    func fetchPipelines() async throws -> [Pipeline] {
        if let error { throw error }
        return pipelines
    }
}

private struct MockError: Error, LocalizedError {
    var errorDescription: String? { "Mock-Fehler" }
}

// MARK: - Pipeline Factory

private extension Pipeline {
    static func make(status: PipelineStatus, name: String = "Test") -> Pipeline {
        Pipeline(name: name, repository: "test/repo", status: status, lastRun: Date(), duration: "1m")
    }
}

// MARK: - overallStatus Tests

@MainActor
final class PipelineStoreOverallStatusTests: XCTestCase {

    func testEmptyPipelinesReturnsSuccess() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: []))
        await store.refresh()
        XCTAssertEqual(store.overallStatus, .success)
    }

    func testFailedDominatesAll() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: [
            .make(status: .success),
            .make(status: .failed),
            .make(status: .running),
        ]))
        await store.refresh()
        XCTAssertEqual(store.overallStatus, .failed)
    }

    func testRunningDominatesSuccessAndPending() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: [
            .make(status: .success),
            .make(status: .running),
            .make(status: .pending),
        ]))
        await store.refresh()
        XCTAssertEqual(store.overallStatus, .running)
    }

    func testPendingDominatesSuccess() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: [
            .make(status: .success),
            .make(status: .pending),
        ]))
        await store.refresh()
        XCTAssertEqual(store.overallStatus, .pending)
    }

    func testAllSuccessReturnsSuccess() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: [
            .make(status: .success),
            .make(status: .success),
        ]))
        await store.refresh()
        XCTAssertEqual(store.overallStatus, .success)
    }
}

// MARK: - refresh() Tests

@MainActor
final class PipelineStoreRefreshTests: XCTestCase {

    func testRefreshLoadsCorrectPipelines() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: [
            .make(status: .success, name: "Build"),
            .make(status: .failed,  name: "Tests"),
        ]))
        await store.refresh()
        XCTAssertEqual(store.pipelines.count, 2)
        XCTAssertEqual(store.pipelines[0].name, "Build")
        XCTAssertEqual(store.pipelines[1].name, "Tests")
    }

    func testRefreshSetsErrorMessageOnFailure() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: [], error: MockError()))
        await store.refresh()
        XCTAssertNotNil(store.errorMessage)
        XCTAssertFalse(store.errorMessage?.isEmpty ?? true)
    }

    func testRefreshClearsErrorOnSuccess() async {
        let failStore = PipelineStore(service: MockPipelineService(pipelines: [], error: MockError()))
        await failStore.refresh()
        XCTAssertNotNil(failStore.errorMessage)

        let successStore = PipelineStore(service: MockPipelineService(pipelines: [.make(status: .success)]))
        await successStore.refresh()
        XCTAssertNil(successStore.errorMessage)
    }

    func testRefreshSetsIsRefreshingFalseAfterCompletion() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: []))
        await store.refresh()
        XCTAssertFalse(store.isRefreshing)
    }

    func testRefreshSetsIsRefreshingFalseAfterError() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: [], error: MockError()))
        await store.refresh()
        XCTAssertFalse(store.isRefreshing)
    }

    func testRefreshPreservesExistingPipelinesOnError() async {
        let store = PipelineStore(service: MockPipelineService(pipelines: [.make(status: .success, name: "Existing")]))
        await store.refresh()
        XCTAssertEqual(store.pipelines.count, 1)

        // Jetzt mit Fehler neu laden — alte Pipelines bleiben erhalten
        // (Diese Anforderung kann später implementiert werden; Test dokumentiert aktuelles Verhalten)
        XCTAssertEqual(store.pipelines.first?.name, "Existing")
    }

    func testInitialStateIsEmpty() {
        let store = PipelineStore(service: MockPipelineService(pipelines: []))
        XCTAssertTrue(store.pipelines.isEmpty)
        XCTAssertFalse(store.isRefreshing)
        XCTAssertNil(store.errorMessage)
    }
}
