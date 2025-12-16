import XCTest
@testable import ARCLogger

final class ConsoleDestinationTests: XCTestCase {

    func testDefaultMinimumLevel() {
        let destination = ConsoleDestination()
        XCTAssertEqual(destination.minimumLevel, .debug)
    }

    func testCustomMinimumLevel() {
        let destination = ConsoleDestination(minimumLevel: .error)
        XCTAssertEqual(destination.minimumLevel, .error)
    }

    func testWriteDoesNotCrash() {
        let destination = ConsoleDestination()
        let context = LogContext(category: "Test", subsystem: "com.test")

        destination.write(level: .info, message: "Test", context: context)

        XCTAssertTrue(true)
    }
}
