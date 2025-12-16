import XCTest
@testable import ARCLogger

final class LogContextTests: XCTestCase {

    func testMinimalInitialization() {
        let context = LogContext(
            category: "Test",
            subsystem: "com.test"
        )

        XCTAssertEqual(context.category, "Test")
        XCTAssertEqual(context.subsystem, "com.test")
        XCTAssertNil(context.file)
        XCTAssertNil(context.function)
        XCTAssertNil(context.line)
        XCTAssertTrue(context.metadata.isEmpty)
    }

    func testFullInitialization() {
        let metadata = ["key": "value", "userId": "123"]

        let context = LogContext(
            category: "Network",
            subsystem: "com.arclabs.network",
            file: "HTTPClient.swift",
            function: "request(_:)",
            line: 42,
            metadata: metadata
        )

        XCTAssertEqual(context.category, "Network")
        XCTAssertEqual(context.subsystem, "com.arclabs.network")
        XCTAssertEqual(context.file, "HTTPClient.swift")
        XCTAssertEqual(context.function, "request(_:)")
        XCTAssertEqual(context.line, 42)
        XCTAssertEqual(context.metadata, metadata)
    }

    func testMetadataRetention() {
        let metadata = [
            "requestId": "abc-123",
            "userId": "user-456"
        ]

        let context = LogContext(
            category: "Test",
            subsystem: "com.test",
            metadata: metadata
        )

        XCTAssertEqual(context.metadata.count, 2)
        XCTAssertEqual(context.metadata["requestId"], "abc-123")
        XCTAssertEqual(context.metadata["userId"], "user-456")
    }
}
