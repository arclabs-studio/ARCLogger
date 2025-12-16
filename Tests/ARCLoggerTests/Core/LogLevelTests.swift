import XCTest
@testable import ARCLogger

final class LogLevelTests: XCTestCase {

    func testLogLevelOrdering() {
        XCTAssertLessThan(LogLevel.debug, .info)
        XCTAssertLessThan(LogLevel.info, .warning)
        XCTAssertLessThan(LogLevel.warning, .error)
        XCTAssertLessThan(LogLevel.error, .critical)
    }

    func testLogLevelEquality() {
        XCTAssertEqual(LogLevel.debug, .debug)
        XCTAssertNotEqual(LogLevel.debug, .info)
    }

    func testLogLevelEmojis() {
        XCTAssertEqual(LogLevel.debug.emoji, "🔍")
        XCTAssertEqual(LogLevel.info.emoji, "ℹ️")
        XCTAssertEqual(LogLevel.warning.emoji, "⚠️")
        XCTAssertEqual(LogLevel.error.emoji, "❌")
        XCTAssertEqual(LogLevel.critical.emoji, "🔥")
    }

    func testLogLevelRawValues() {
        XCTAssertEqual(LogLevel.debug.rawValue, 0)
        XCTAssertEqual(LogLevel.info.rawValue, 1)
        XCTAssertEqual(LogLevel.warning.rawValue, 2)
        XCTAssertEqual(LogLevel.error.rawValue, 3)
        XCTAssertEqual(LogLevel.critical.rawValue, 4)
    }
}
