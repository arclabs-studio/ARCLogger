import Foundation
@testable import ARCLogger

/// Mock destination that captures logged messages for testing.
final class MockLogDestination: LogDestination, @unchecked Sendable {
    var minimumLevel: LogLevel

    // Captured data
    private(set) var loggedEntries: [LogEntry] = []
    private(set) var callCount = 0

    // Computed helpers
    var lastEntry: LogEntry? { loggedEntries.last }
    var lastLevel: LogLevel? { loggedEntries.last?.level }
    var lastMessage: String? { loggedEntries.last?.message }

    init(minimumLevel: LogLevel = .debug) {
        self.minimumLevel = minimumLevel
    }

    func write(_ entry: LogEntry, isProduction: Bool) {
        guard entry.level >= minimumLevel else { return }
        loggedEntries.append(entry)
        callCount += 1
    }

    func reset() {
        loggedEntries.removeAll()
        callCount = 0
    }

    func messages(for level: LogLevel) -> [String] {
        loggedEntries
            .filter { $0.level == level }
            .map { $0.message }
    }
}
