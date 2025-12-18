// ConsoleDestinationTests.swift
// ARCLoggerTests
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation
import Testing
@testable import ARCLogger

@Suite("ConsoleDestination Tests")
struct ConsoleDestinationTests {

    // MARK: - Initialization Tests

    @Test("Default initialization sets expected values")
    func defaultInitialization() {
        let destination = ConsoleDestination()

        #expect(destination.minimumLevel == .debug)
        #expect(destination.includeTimestamp == true)
        #expect(destination.includeSourceLocation == false)
        #expect(destination.useEmoji == true)
    }

    @Test("Custom initialization preserves values")
    func customInitialization() {
        let destination = ConsoleDestination(
            minimumLevel: .warning,
            includeTimestamp: false,
            includeSourceLocation: true,
            useEmoji: false
        )

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

    @Test("Timestamp only configuration")
    func timestampOnlyConfig() {
        let destination = ConsoleDestination(
            includeTimestamp: true,
            includeSourceLocation: false,
            useEmoji: false
        )

        #expect(destination.includeTimestamp == true)
        #expect(destination.includeSourceLocation == false)
        #expect(destination.useEmoji == false)
    }

    @Test("Source location only configuration")
    func sourceLocationOnlyConfig() {
        let destination = ConsoleDestination(
            includeTimestamp: false,
            includeSourceLocation: true,
            useEmoji: false
        )

        #expect(destination.includeTimestamp == false)
        #expect(destination.includeSourceLocation == true)
        #expect(destination.useEmoji == false)
    }

    @Test("Minimal configuration")
    func minimalConfig() {
        let destination = ConsoleDestination(
            includeTimestamp: false,
            includeSourceLocation: false,
            useEmoji: false
        )

        #expect(destination.includeTimestamp == false)
        #expect(destination.includeSourceLocation == false)
        #expect(destination.useEmoji == false)
    }
}
