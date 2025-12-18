// ConsoleDestination.swift
// ARCLogger
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation
import os.log

/// A log destination that writes to the system console.
///
/// Uses Apple's unified logging system (os.log) for optimal performance
/// and integration with Console.app and Xcode.
///
/// ## Example
///
/// ```swift
/// let console = ConsoleDestination(
///     minimumLevel: .info,
///     includeTimestamp: true
/// )
/// ```
public struct ConsoleDestination: LogDestination {
    /// The minimum log level to output.
    public let minimumLevel: LogLevel

    /// Whether to include timestamps in output.
    public let includeTimestamp: Bool

    /// Whether to include source location in output.
    public let includeSourceLocation: Bool

    /// Whether to use emoji prefixes for log levels.
    public let useEmoji: Bool

    private let dateFormatter: DateFormatter

    /// Creates a new console destination.
    ///
    /// - Parameters:
    ///   - minimumLevel: Minimum level to log. Defaults to `.debug`.
    ///   - includeTimestamp: Include timestamp in output. Defaults to `true`.
    ///   - includeSourceLocation: Include file/line info. Defaults to `false`.
    ///   - useEmoji: Use emoji prefixes. Defaults to `true`.
    public init(
        minimumLevel: LogLevel = .debug,
        includeTimestamp: Bool = true,
        includeSourceLocation: Bool = false,
        useEmoji: Bool = true
    ) {
        self.minimumLevel = minimumLevel
        self.includeTimestamp = includeTimestamp
        self.includeSourceLocation = includeSourceLocation
        self.useEmoji = useEmoji
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }

    // MARK: - LogDestination

    public func write(_ entry: LogEntry, isProduction: Bool) {
        guard entry.level >= minimumLevel else { return }
        let formatted = format(entry, isProduction: isProduction)
        print(formatted)
    }

    // MARK: - Private

    private func format(_ entry: LogEntry, isProduction: Bool) -> String {
        var components: [String] = []

        if includeTimestamp {
            components.append("[\(dateFormatter.string(from: entry.timestamp))]")
        }

        if useEmoji {
            components.append(entry.level.emoji)
        }

        components.append("[\(entry.level)]")

        if includeSourceLocation {
            components.append("[\(entry.fileName):\(entry.line)]")
        }

        components.append(entry.message)

        if !entry.metadata.isEmpty {
            let metadataString = entry.metadata
                .map { key, value in "\(key)=\(value.redacted(isProduction: isProduction))" }
                .joined(separator: ", ")
            components.append("{\(metadataString)}")
        }

        return components.joined(separator: " ")
    }
}
