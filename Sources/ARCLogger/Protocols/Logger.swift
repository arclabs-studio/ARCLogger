// Logger.swift
// ARCLogger
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation

/// A protocol defining the interface for logging operations.
///
/// Implement this protocol to create custom loggers with different
/// behaviors or output formats.
///
/// ## Example
///
/// ```swift
/// struct MyLogger: Logger {
///     func log(
///         _ message: String,
///         level: LogLevel,
///         metadata: [String: LogValue],
///         file: String,
///         function: String,
///         line: Int
///     ) {
///         // Custom logging implementation
///     }
/// }
/// ```
public protocol Logger: Sendable {
    /// Logs a message with the specified level and metadata.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The severity level of the log.
    ///   - metadata: Additional structured data.
    ///   - file: The source file (auto-populated).
    ///   - function: The function name (auto-populated).
    ///   - line: The line number (auto-populated).
    func log(
        _ message: String,
        level: LogLevel,
        metadata: [String: LogValue],
        file: String,
        function: String,
        line: Int
    )
}

// MARK: - Convenience Methods

extension Logger {
    /// Logs a debug message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Additional structured data.
    ///   - file: The source file (auto-populated).
    ///   - function: The function name (auto-populated).
    ///   - line: The line number (auto-populated).
    public func debug(
        _ message: String,
        metadata: [String: LogValue] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs an info message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Additional structured data.
    ///   - file: The source file (auto-populated).
    ///   - function: The function name (auto-populated).
    ///   - line: The line number (auto-populated).
    public func info(
        _ message: String,
        metadata: [String: LogValue] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs a warning message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Additional structured data.
    ///   - file: The source file (auto-populated).
    ///   - function: The function name (auto-populated).
    ///   - line: The line number (auto-populated).
    public func warning(
        _ message: String,
        metadata: [String: LogValue] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs an error message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Additional structured data.
    ///   - file: The source file (auto-populated).
    ///   - function: The function name (auto-populated).
    ///   - line: The line number (auto-populated).
    public func error(
        _ message: String,
        metadata: [String: LogValue] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .error, metadata: metadata, file: file, function: function, line: line)
    }

    /// Logs a critical message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - metadata: Additional structured data.
    ///   - file: The source file (auto-populated).
    ///   - function: The function name (auto-populated).
    ///   - line: The line number (auto-populated).
    public func critical(
        _ message: String,
        metadata: [String: LogValue] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .critical, metadata: metadata, file: file, function: function, line: line)
    }
}
