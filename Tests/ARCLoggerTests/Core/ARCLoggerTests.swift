import XCTest
@testable import ARCLogger

final class ARCLoggerTests: XCTestCase {

    func testDebugLogging() {
        let (logger, mock) = LogTestHelpers.makeTestLogger()

        logger.debug("Debug message")

        XCTAssertEqual(mock.callCount, 1)
        XCTAssertEqual(mock.lastLevel, .debug)
        XCTAssertEqual(mock.lastMessage, "Debug message")
    }

    func testInfoLogging() {
        let (logger, mock) = LogTestHelpers.makeTestLogger()

        logger.info("Info message")

        XCTAssertEqual(mock.callCount, 1)
        XCTAssertEqual(mock.lastLevel, .info)
        XCTAssertEqual(mock.lastMessage, "Info message")
    }

    func testWarningLogging() {
        let (logger, mock) = LogTestHelpers.makeTestLogger()

        logger.warning("Warning message")

        XCTAssertEqual(mock.callCount, 1)
        XCTAssertEqual(mock.lastLevel, .warning)
        XCTAssertEqual(mock.lastMessage, "Warning message")
    }

    func testErrorLogging() {
        let (logger, mock) = LogTestHelpers.makeTestLogger()

        logger.error("Error message")

        XCTAssertEqual(mock.callCount, 1)
        XCTAssertEqual(mock.lastLevel, .error)
        XCTAssertEqual(mock.lastMessage, "Error message")
    }

    func testCriticalLogging() {
        let (logger, mock) = LogTestHelpers.makeTestLogger()

        logger.critical("Critical message")

        XCTAssertEqual(mock.callCount, 1)
        XCTAssertEqual(mock.lastLevel, .critical)
        XCTAssertEqual(mock.lastMessage, "Critical message")
    }

    func testLoggingWithMetadata() {
        let (logger, mock) = LogTestHelpers.makeTestLogger()

        logger.info("User action", metadata: ["userId": "123", "action": "login"])

        XCTAssertEqual(mock.callCount, 1)
        let context = mock.lastContext
        XCTAssertEqual(context?.metadata["userId"], "123")
        XCTAssertEqual(context?.metadata["action"], "login")
    }

    func testErrorLoggingWithError() {
        let (logger, mock) = LogTestHelpers.makeTestLogger()

        enum TestError: Error {
            case testFailure
        }

        logger.error("Operation failed", error: TestError.testFailure)

        XCTAssertEqual(mock.callCount, 1)
        let metadata = mock.lastContext?.metadata
        XCTAssertNotNil(metadata?["error"])
    }

    func testMultipleDestinations() {
        let mock1 = MockLogDestination()
        let mock2 = MockLogDestination()

        let logger = ARCLogger(
            category: "Test",
            subsystem: "com.test",
            destinations: [mock1, mock2]
        )

        logger.info("Broadcast message")

        XCTAssertEqual(mock1.callCount, 1)
        XCTAssertEqual(mock2.callCount, 1)
        XCTAssertEqual(mock1.lastMessage, "Broadcast message")
        XCTAssertEqual(mock2.lastMessage, "Broadcast message")
    }

    func testDifferentMinimumLevelsInDestinations() {
        let debugMock = MockLogDestination(minimumLevel: .debug)
        let errorMock = MockLogDestination(minimumLevel: .error)

        let logger = ARCLogger(
            category: "Test",
            subsystem: "com.test",
            destinations: [debugMock, errorMock]
        )

        logger.debug("Debug message")
        logger.info("Info message")
        logger.error("Error message")

        XCTAssertEqual(debugMock.callCount, 3)
        XCTAssertEqual(errorMock.callCount, 1)
    }
}
