import Foundation
@testable import ARCLogger

/// Mock destination that captures logged messages for testing.
final class MockLogDestination: LogDestination, @unchecked Sendable {
    var minimumLevel: LogLevel

    // Captured data
    private(set) var loggedMessages: [(level: LogLevel, message: String, context: LogContext)] = []
    private(set) var callCount = 0

    // Computed helpers
    var lastLevel: LogLevel? { loggedMessages.last?.level }
    var lastMessage: String? { loggedMessages.last?.message }
    var lastContext: LogContext? { loggedMessages.last?.context }

    init(minimumLevel: LogLevel = .debug) {
        self.minimumLevel = minimumLevel
    }

    func write(level: LogLevel, message: String, context: LogContext) {
        guard level >= minimumLevel else { return }
        loggedMessages.append((level, message, context))
        callCount += 1
    }

    func reset() {
        loggedMessages.removeAll()
        callCount = 0
    }

    func messages(for level: LogLevel) -> [String] {
        loggedMessages
            .filter { $0.level == level }
            .map { $0.message }
    }
}
