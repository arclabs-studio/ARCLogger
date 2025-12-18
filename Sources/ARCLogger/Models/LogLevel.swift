// LogLevel.swift
// ARCLogger
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation

/// Represents the severity level of a log message.
///
/// Log levels are ordered from least to most severe:
/// - `debug`: Detailed information for debugging purposes
/// - `info`: General information about program execution
/// - `warning`: Potentially problematic situations
/// - `error`: Error conditions that allow continued execution
/// - `critical`: Severe errors that may cause program termination
///
/// ## Example
///
/// ```swift
/// let level: LogLevel = .info
/// if level >= .warning {
///     // Handle elevated severity
/// }
/// ```
public enum LogLevel: Int, Sendable, Comparable, CaseIterable, CustomStringConvertible {
    /// Detailed debugging information.
    ///
    /// Use for verbose output during development and troubleshooting.
    case debug = 0

    /// General informational messages.
    ///
    /// Use for routine operational messages.
    case info = 1

    /// Warning conditions.
    ///
    /// Use when something unexpected occurred but execution can continue.
    case warning = 2

    /// Error conditions.
    ///
    /// Use when an error occurred but the application can recover.
    case error = 3

    /// Critical conditions.
    ///
    /// Use for severe errors that may cause program termination.
    case critical = 4

    // MARK: - Comparable

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        switch self {
        case .debug: "DEBUG"
        case .info: "INFO"
        case .warning: "WARNING"
        case .error: "ERROR"
        case .critical: "CRITICAL"
        }
    }

    /// Returns an emoji representation of the log level.
    public var emoji: String {
        switch self {
        case .debug: "🔍"
        case .info: "ℹ️"
        case .warning: "⚠️"
        case .error: "❌"
        case .critical: "🔥"
        }
    }
}
