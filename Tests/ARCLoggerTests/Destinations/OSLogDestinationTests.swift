import XCTest
@testable import ARCLogger

final class OSLogDestinationTests: XCTestCase {

    func testInitialization() {
        let destination = OSLogDestination(
            subsystem: "com.test",
            category: "TestCategory",
            minimumLevel: .info
        )

        XCTAssertEqual(destination.minimumLevel, .info)
    }

    func testDefaultMinimumLevel() {
        let destination = OSLogDestination(
            subsystem: "com.test",
            category: "Test"
        )

        XCTAssertEqual(destination.minimumLevel, .info)
    }

    func testWriteDoesNotCrash() {
        let destination = OSLogDestination(
            subsystem: "com.test.oslog",
            category: "Test"
        )

        let context = LogContext(category: "Test", subsystem: "com.test")

        destination.write(level: .debug, message: "Debug test", context: context)
        destination.write(level: .info, message: "Info test", context: context)
        destination.write(level: .warning, message: "Warning test", context: context)
        destination.write(level: .error, message: "Error test", context: context)
        destination.write(level: .critical, message: "Critical test", context: context)

        XCTAssertTrue(true)
    }
}
