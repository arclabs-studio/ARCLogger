// LogEntryTests.swift
// ARCLoggerTests
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation
import Testing
@testable import ARCLogger

@Suite("LogEntry Tests")
struct LogEntryTests {

    // MARK: - Initialization Tests

    @Test("LogEntry initializes with all parameters")
    func initializesWithAllParams() {
        let timestamp = Date()
        let metadata: [String: LogValue] = ["key": .public("value")]

        let entry = LogEntry(
            message: "Test message",
            level: .info,
            metadata: metadata,
            timestamp: timestamp,
            file: "/path/to/File.swift",
            function: "testFunction()",
            line: 42
        )

        #expect(entry.message == "Test message")
        #expect(entry.level == .info)
        #expect(entry.metadata.count == 1)
        #expect(entry.timestamp == timestamp)
        #expect(entry.file == "/path/to/File.swift")
        #expect(entry.function == "testFunction()")
        #expect(entry.line == 42)
    }

    @Test("LogEntry initializes with default values")
    func initializesWithDefaults() {
        let entry = LogEntry(message: "Test", level: .debug)

        #expect(entry.message == "Test")
        #expect(entry.level == .debug)
        #expect(entry.metadata.isEmpty)
        #expect(!entry.file.isEmpty)
        #expect(!entry.function.isEmpty)
        #expect(entry.line > 0)
    }

    // MARK: - Message Tests

    @Test("Message can be empty")
    func emptyMessageAllowed() {
        let entry = LogEntry(message: "", level: .info)
        #expect(entry.message == "")
    }

    @Test("Message preserves whitespace")
    func whitespacePreserved() {
        let entry = LogEntry(message: "  spaced  message  ", level: .info)
        #expect(entry.message == "  spaced  message  ")
    }

    @Test("Message preserves newlines")
    func newlinesPreserved() {
        let entry = LogEntry(message: "line1\nline2\nline3", level: .info)
        #expect(entry.message.contains("\n"))
    }

    // MARK: - Level Tests

    @Test("All log levels can be used", arguments: LogLevel.allCases)
    func allLevelsWork(level: LogLevel) {
        let entry = LogEntry(message: "Test", level: level)
        #expect(entry.level == level)
    }

    // MARK: - Metadata Tests

    @Test("Metadata can be empty")
    func emptyMetadata() {
        let entry = LogEntry(message: "Test", level: .info, metadata: [:])
        #expect(entry.metadata.isEmpty)
    }

    @Test("Metadata with multiple entries")
    func multipleMetadataEntries() {
        let metadata: [String: LogValue] = [
            "key1": .public("value1"),
            "key2": .private("value2"),
            "key3": .sensitive("value3")
        ]
        let entry = LogEntry(message: "Test", level: .info, metadata: metadata)

        #expect(entry.metadata.count == 3)
        #expect(entry.metadata["key1"]?.privacy == .public)
        #expect(entry.metadata["key2"]?.privacy == .private)
        #expect(entry.metadata["key3"]?.privacy == .sensitive)
    }

    // MARK: - Timestamp Tests

    @Test("Timestamp is set correctly")
    func timestampIsSet() {
        let before = Date()
        let entry = LogEntry(message: "Test", level: .info)
        let after = Date()

        #expect(entry.timestamp >= before)
        #expect(entry.timestamp <= after)
    }

    @Test("Custom timestamp is preserved")
    func customTimestampPreserved() {
        let customDate = Date(timeIntervalSince1970: 1000000)
        let entry = LogEntry(message: "Test", level: .info, timestamp: customDate)
        #expect(entry.timestamp == customDate)
    }

    // MARK: - File Name Tests

    @Test("fileName extracts last path component")
    func fileNameExtractsLastComponent() {
        let entry = LogEntry(
            message: "Test",
            level: .info,
            file: "/Users/developer/Project/Sources/File.swift",
            function: "test()",
            line: 1
        )
        #expect(entry.fileName == "File.swift")
    }

    @Test("fileName handles simple file names")
    func fileNameHandlesSimple() {
        let entry = LogEntry(
            message: "Test",
            level: .info,
            file: "File.swift",
            function: "test()",
            line: 1
        )
        #expect(entry.fileName == "File.swift")
    }

    @Test("fileName handles paths with spaces")
    func fileNameHandlesSpaces() {
        let entry = LogEntry(
            message: "Test",
            level: .info,
            file: "/path/with spaces/My File.swift",
            function: "test()",
            line: 1
        )
        #expect(entry.fileName == "My File.swift")
    }

    // MARK: - Source Location Tests

    @Test("Source location captures current file")
    func capturesCurrentFile() {
        let entry = LogEntry(message: "Test", level: .info)
        #expect(entry.file.contains("LogEntryTests.swift"))
    }

    @Test("Line number is captured correctly")
    func lineNumberCaptured() {
        let entry = LogEntry(message: "Test", level: .info)
        #expect(entry.line > 0)
    }
}
