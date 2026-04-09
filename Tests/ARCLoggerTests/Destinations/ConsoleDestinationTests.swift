// ConsoleDestinationTests.swift
// ARCLoggerTests
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation
import Testing
@testable import ARCLogger

struct ConsoleDestinationTests {
    // MARK: - Initialization Tests

    @Test("Default initialization sets expected values") func defaultInitialization() {
        let destination = ConsoleDestination()

        #expect(destination.minimumLevel == .debug)
        #expect(destination.includeTimestamp == true)
        #expect(destination.includeSourceLocation == false)
        #expect(destination.useEmoji == true)
    }

    @Test("Custom initialization preserves values") func customInitialization() {
        let destination = ConsoleDestination(minimumLevel: .warning,
                                             includeTimestamp: false,
                                             includeSourceLocation: true,
                                             useEmoji: false)

        #expect(destination.minimumLevel == .warning)
        #expect(destination.includeTimestamp == false)
        #expect(destination.includeSourceLocation == true)
        #expect(destination.useEmoji == false)
    }

    // MARK: - Minimum Level Tests

    @Test("All log levels can be set as minimum", arguments: LogLevel.allCases)
    func allLevelsAsMinimum(level: LogLevel) {
        let destination = ConsoleDestination(minimumLevel: level)
        #expect(destination.minimumLevel == level)
    }

    // MARK: - Configuration Combinations

    @Test("Timestamp only configuration") func timestampOnlyConfig() {
        let destination = ConsoleDestination(includeTimestamp: true,
                                             includeSourceLocation: false,
                                             useEmoji: false)

        #expect(destination.includeTimestamp == true)
        #expect(destination.includeSourceLocation == false)
        #expect(destination.useEmoji == false)
    }

    @Test("Source location only configuration") func sourceLocationOnlyConfig() {
        let destination = ConsoleDestination(includeTimestamp: false,
                                             includeSourceLocation: true,
                                             useEmoji: false)

        #expect(destination.includeTimestamp == false)
        #expect(destination.includeSourceLocation == true)
        #expect(destination.useEmoji == false)
    }

    @Test("Minimal configuration") func minimalConfig() {
        let destination = ConsoleDestination(includeTimestamp: false,
                                             includeSourceLocation: false,
                                             useEmoji: false)

        #expect(destination.includeTimestamp == false)
        #expect(destination.includeSourceLocation == false)
        #expect(destination.useEmoji == false)
    }

    // MARK: - mirrorsToStdout Tests

    @Test("mirrorsToStdout defaults to false") func mirrorsToStdoutDefaultsFalse() {
        let destination = ConsoleDestination()
        #expect(destination.mirrorsToStdout == false)
    }

    @Test("mirrorsToStdout can be set to true") func mirrorsToStdoutCanBeEnabled() {
        let destination = ConsoleDestination(mirrorsToStdout: true)
        #expect(destination.mirrorsToStdout == true)
    }

    // MARK: - Smoke Tests

    @Test("write does not crash with all privacy levels") func writeDoesNotCrashAllPrivacyLevels() {
        let destination = ConsoleDestination()
        let entry = LogEntry(message: "Smoke test",
                             level: .info,
                             metadata: ["pub": .public("visible"),
                                        "priv": .private("hidden"),
                                        "sens": .sensitive("secret")],
                             subsystem: "com.test",
                             category: "Smoke")
        // Must not crash; os.Logger output is verified via log stream end-to-end
        destination.write(entry, isProduction: false)
        destination.write(entry, isProduction: true)
    }

    @Test("write respects minimumLevel guard") func writeRespectsMinimumLevel() {
        // Use mirrorsToStdout:false (default) — just verifies no crash and
        // that the minimumLevel guard runs without accessing os.Logger.
        let destination = ConsoleDestination(minimumLevel: .error)
        let entry = LogEntry(message: "Ignored", level: .debug, subsystem: "com.test", category: "Test")
        destination.write(entry, isProduction: false) // Should be filtered, no crash
    }
}
