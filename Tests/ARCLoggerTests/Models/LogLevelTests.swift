// LogLevelTests.swift
// ARCLoggerTests
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Testing
@testable import ARCLogger

@Suite("LogLevel Tests")
struct LogLevelTests {

    // MARK: - Raw Value Tests

    @Test("LogLevel raw values are ordered correctly")
    func rawValuesAreOrdered() {
        #expect(LogLevel.debug.rawValue == 0)
        #expect(LogLevel.info.rawValue == 1)
        #expect(LogLevel.warning.rawValue == 2)
        #expect(LogLevel.error.rawValue == 3)
        #expect(LogLevel.critical.rawValue == 4)
    }

    // MARK: - Comparable Tests

    @Test("Debug is less than all other levels")
    func debugIsLessThanAll() {
        #expect(LogLevel.debug < LogLevel.info)
        #expect(LogLevel.debug < LogLevel.warning)
        #expect(LogLevel.debug < LogLevel.error)
        #expect(LogLevel.debug < LogLevel.critical)
    }

    @Test("Critical is greater than all other levels")
    func criticalIsGreaterThanAll() {
        #expect(LogLevel.critical > LogLevel.debug)
        #expect(LogLevel.critical > LogLevel.info)
        #expect(LogLevel.critical > LogLevel.warning)
        #expect(LogLevel.critical > LogLevel.error)
    }

    @Test("Same log levels are equal")
    func sameLevelsAreEqual() {
        #expect(LogLevel.info == LogLevel.info)
        #expect(LogLevel.error == LogLevel.error)
    }

    @Test("LogLevel comparison chain is correct")
    func comparisonChainIsCorrect() {
        #expect(LogLevel.debug < LogLevel.info)
        #expect(LogLevel.info < LogLevel.warning)
        #expect(LogLevel.warning < LogLevel.error)
        #expect(LogLevel.error < LogLevel.critical)
    }

    // MARK: - Description Tests

    @Test("LogLevel descriptions are correct", arguments: [
        (LogLevel.debug, "DEBUG"),
        (LogLevel.info, "INFO"),
        (LogLevel.warning, "WARNING"),
        (LogLevel.error, "ERROR"),
        (LogLevel.critical, "CRITICAL")
    ])
    func descriptionsAreCorrect(level: LogLevel, expected: String) {
        #expect(level.description == expected)
    }

    // MARK: - Emoji Tests

    @Test("LogLevel emojis are set", arguments: LogLevel.allCases)
    func emojisAreSet(level: LogLevel) {
        #expect(!level.emoji.isEmpty)
    }

    @Test("LogLevel emojis are unique")
    func emojisAreUnique() {
        let emojis = LogLevel.allCases.map { $0.emoji }
        let uniqueEmojis = Set(emojis)
        #expect(emojis.count == uniqueEmojis.count)
    }

    // MARK: - CaseIterable Tests

    @Test("LogLevel has all expected cases")
    func hasAllCases() {
        #expect(LogLevel.allCases.count == 5)
        #expect(LogLevel.allCases.contains(.debug))
        #expect(LogLevel.allCases.contains(.info))
        #expect(LogLevel.allCases.contains(.warning))
        #expect(LogLevel.allCases.contains(.error))
        #expect(LogLevel.allCases.contains(.critical))
    }
}
