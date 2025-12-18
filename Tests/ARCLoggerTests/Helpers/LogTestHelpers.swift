import Foundation
@testable import ARCLogger

enum LogTestHelpers {
    /// Creates a test logger with a mock destination.
    static func makeTestLogger(
        category: String = "Test",
        subsystem: String = "com.test",
        minimumLevel: LogLevel = .debug
    ) -> (logger: ARCLogger, mock: MockLogDestination) {
        let mock = MockLogDestination(minimumLevel: minimumLevel)
        let logger = ARCLogger(
            destinations: [mock],
            subsystem: subsystem,
            category: category
        )
        return (logger, mock)
    }
}
