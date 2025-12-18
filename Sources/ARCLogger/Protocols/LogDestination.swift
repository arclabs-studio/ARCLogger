// LogDestination.swift
// ARCLogger
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation

/// A protocol defining a destination for log output.
///
/// Implement this protocol to create custom log destinations such as
/// file loggers, network loggers, or analytics integrations.
///
/// ## Example
///
/// ```swift
/// final class FileDestination: LogDestination {
///     let fileURL: URL
///
///     init(fileURL: URL) {
///         self.fileURL = fileURL
///     }
///
///     func write(_ entry: LogEntry, isProduction: Bool) {
///         let formatted = format(entry, isProduction: isProduction)
///         // Write to file...
///     }
/// }
/// ```
public protocol LogDestination: Sendable {
    /// Writes a log entry to this destination.
    ///
    /// - Parameters:
    ///   - entry: The log entry to write.
    ///   - isProduction: Whether the environment is production.
    func write(_ entry: LogEntry, isProduction: Bool)

    /// The minimum log level this destination will accept.
    ///
    /// Entries below this level will be filtered out.
    var minimumLevel: LogLevel { get }
}

// MARK: - Default Implementation

extension LogDestination {
    /// Default minimum level is debug (accepts all logs).
    public var minimumLevel: LogLevel { .debug }
}
