// LogEntry.swift
// ARCLogger
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation

/// A structured log entry containing message, level, and metadata.
///
/// Log entries capture all information about a single log event including
/// the message, severity level, timestamp, source location, and custom metadata.
///
/// ## Example
///
/// ```swift
/// let entry = LogEntry(
///     message: "User action completed",
///     level: .info,
///     metadata: ["userId": .public("123")],
///     file: #file,
///     function: #function,
///     line: #line
/// )
/// ```
public struct LogEntry: Sendable {
    /// The log message.
    public let message: String

    /// The severity level of this log entry.
    public let level: LogLevel

    /// Custom metadata associated with this log entry.
    public let metadata: [String: LogValue]

    /// The timestamp when this entry was created.
    public let timestamp: Date

    /// The source file where the log was called.
    public let file: String

    /// The function where the log was called.
    public let function: String

    /// The line number where the log was called.
    public let line: Int

    /// Creates a new log entry with the specified parameters.
    ///
    /// - Parameters:
    ///   - message: The log message.
    ///   - level: The severity level.
    ///   - metadata: Custom metadata dictionary. Defaults to empty.
    ///   - timestamp: The timestamp. Defaults to current date.
    ///   - file: The source file. Defaults to the caller's file.
    ///   - function: The function name. Defaults to the caller's function.
    ///   - line: The line number. Defaults to the caller's line.
    public init(
        message: String,
        level: LogLevel,
        metadata: [String: LogValue] = [:],
        timestamp: Date = Date(),
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.message = message
        self.level = level
        self.metadata = metadata
        self.timestamp = timestamp
        self.file = file
        self.function = function
        self.line = line
    }

    /// The filename without path.
    public var fileName: String {
        URL(fileURLWithPath: file).lastPathComponent
    }
}
