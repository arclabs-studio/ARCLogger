// ARCLoggerTests.swift
// ARCLoggerTests
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation
import Testing
@testable import ARCLogger

// MARK: - Mock Destination

/// A mock destination for testing that captures log entries.
final class MockDestination: LogDestination, @unchecked Sendable {
    var entries: [LogEntry] = []
    var minimumLevel: LogLevel = .debug
    var writeCallCount = 0
    var lastIsProduction: Bool?

    func write(_ entry: LogEntry, isProduction: Bool) {
        guard entry.level >= minimumLevel else { return }
        entries.append(entry)
        writeCallCount += 1
        lastIsProduction = isProduction
    }

    func reset() {
        entries.removeAll()
        writeCallCount = 0
        lastIsProduction = nil
    }
}

// MARK: - ARCLogger Tests

@Suite("ARCLogger Tests")
struct ARCLoggerTests {

    // MARK: - Initialization Tests

    @Test("Default initialization creates logger with console destination")
    func defaultInitialization() {
        let logger = ARCLogger()

        #expect(logger.destinations.count == 1)
        #expect(logger.isProduction == false)
        #expect(logger.category == "Default")
    }

    @Test("Custom initialization preserves values")
    func customInitialization() {
        let destination = MockDestination()
        let logger = ARCLogger(
            destinations: [destination],
            subsystem: "com.test.app",
            category: "Network",
            isProduction: true
        )

        #expect(logger.destinations.count == 1)
        #expect(logger.subsystem == "com.test.app")
        #expect(logger.category == "Network")
        #expect(logger.isProduction == true)
    }

    @Test("Logger can have multiple destinations")
    func multipleDestinations() {
        let destination1 = MockDestination()
        let destination2 = MockDestination()
        let logger = ARCLogger(destinations: [destination1, destination2])

        #expect(logger.destinations.count == 2)
    }

    // MARK: - Logging Tests

    @Test("Log message is written to destination")
    func logWritesToDestination() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.info("Test message")

        #expect(destination.entries.count == 1)
        #expect(destination.entries.first?.message == "Test message")
        #expect(destination.entries.first?.level == .info)
    }

    @Test("Log message is written to all destinations")
    func logWritesToAllDestinations() {
        let destination1 = MockDestination()
        let destination2 = MockDestination()
        let logger = ARCLogger(destinations: [destination1, destination2])

        logger.info("Test message")

        #expect(destination1.entries.count == 1)
        #expect(destination2.entries.count == 1)
    }

    @Test("Metadata is passed to destination")
    func metadataPassedToDestination() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.info("Test", metadata: ["key": .public("value")])

        #expect(destination.entries.first?.metadata.count == 1)
        #expect(destination.entries.first?.metadata["key"]?.value == "value")
    }

    @Test("Production flag is passed to destination")
    func productionFlagPassed() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination], isProduction: true)

        logger.info("Test")

        #expect(destination.lastIsProduction == true)
    }

    // MARK: - Log Level Convenience Methods

    @Test("Debug convenience method logs at debug level")
    func debugConvenienceMethod() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.debug("Debug message")

        #expect(destination.entries.first?.level == .debug)
    }

    @Test("Info convenience method logs at info level")
    func infoConvenienceMethod() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.info("Info message")

        #expect(destination.entries.first?.level == .info)
    }

    @Test("Warning convenience method logs at warning level")
    func warningConvenienceMethod() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.warning("Warning message")

        #expect(destination.entries.first?.level == .warning)
    }

    @Test("Error convenience method logs at error level")
    func errorConvenienceMethod() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.error("Error message")

        #expect(destination.entries.first?.level == .error)
    }

    @Test("Critical convenience method logs at critical level")
    func criticalConvenienceMethod() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.critical("Critical message")

        #expect(destination.entries.first?.level == .critical)
    }

    // MARK: - Shared Instance Tests

    @Test("Shared instance exists")
    func sharedInstanceExists() {
        let shared = ARCLogger.shared
        #expect(shared.destinations.count == 1)
    }

    @Test("Shared instance is consistent")
    func sharedInstanceIsConsistent() {
        let shared1 = ARCLogger.shared
        let shared2 = ARCLogger.shared
        #expect(shared1.category == shared2.category)
    }

    // MARK: - Source Location Tests

    @Test("Source location is captured in log entry")
    func sourceLocationCaptured() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.info("Test")

        let entry = destination.entries.first
        #expect(entry?.file.contains("ARCLoggerTests.swift") == true)
        #expect(entry?.line ?? 0 > 0)
        #expect(entry?.function.isEmpty == false)
    }

    // MARK: - Edge Cases

    @Test("Empty message is logged")
    func emptyMessageLogged() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.info("")

        #expect(destination.entries.first?.message == "")
    }

    @Test("Unicode message is logged correctly")
    func unicodeMessageLogged() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.info("Hello World")

        #expect(destination.entries.first?.message == "Hello World")
    }

    @Test("Long message is logged")
    func longMessageLogged() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])
        let longMessage = String(repeating: "a", count: 10000)

        logger.info(longMessage)

        #expect(destination.entries.first?.message.count == 10000)
    }

    @Test("Empty metadata is handled")
    func emptyMetadataHandled() {
        let destination = MockDestination()
        let logger = ARCLogger(destinations: [destination])

        logger.info("Test", metadata: [:])

        #expect(destination.entries.first?.metadata.isEmpty == true)
    }

    @Test("Logger works with empty destinations array")
    func emptyDestinationsArray() {
        let logger = ARCLogger(destinations: [])
        // Should not crash
        logger.info("Test")
    }

    // MARK: - Minimum Level Filtering

    @Test("Destination filters logs below minimum level")
    func destinationFiltersLogs() {
        let destination = MockDestination()
        destination.minimumLevel = .warning
        let logger = ARCLogger(destinations: [destination])

        logger.debug("Debug")
        logger.info("Info")
        logger.warning("Warning")
        logger.error("Error")

        #expect(destination.entries.count == 2)
        #expect(destination.entries[0].level == .warning)
        #expect(destination.entries[1].level == .error)
    }
}
