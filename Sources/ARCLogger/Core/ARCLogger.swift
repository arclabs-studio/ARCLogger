// ARCLogger.swift
// ARCLogger
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation

/// The main logger implementation for ARCLogger.
///
/// ARCLogger provides structured, privacy-conscious logging with support
/// for multiple destinations and customizable output formats.
///
/// ## Overview
///
/// ARCLogger is designed to be simple to use while providing powerful
/// features for production applications:
///
/// - **Privacy-conscious**: Automatically redacts sensitive data in production
/// - **Structured logging**: Add metadata to logs for better searchability
/// - **Multiple destinations**: Send logs to console, files, or custom destinations
/// - **Thread-safe**: Safe to use from any thread or actor
///
/// ## Quick Start
///
/// ```swift
/// import ARCLogger
///
/// // Create a logger
/// let logger = ARCLogger()
///
/// // Log messages at different levels
/// logger.debug("Starting operation")
/// logger.info("User logged in", metadata: ["userId": .public("123")])
/// logger.warning("Cache miss")
/// logger.error("Failed to save", metadata: ["error": .public("timeout")])
/// logger.critical("Database connection lost")
/// ```
///
/// ## Privacy-Conscious Logging
///
/// ```swift
/// logger.info("User authenticated", metadata: [
///     "userId": .public("12345"),          // Always visible
///     "email": .private("user@test.com"),  // Hidden in production
///     "token": .sensitive("abc123")         // Always hidden
/// ])
/// ```
public struct ARCLogger: Logger, Sendable {
    // MARK: - Properties

    /// The destinations where logs will be sent.
    public let destinations: [any LogDestination]

    /// Whether the environment is production.
    public let isProduction: Bool

    /// The subsystem identifier for this logger.
    public let subsystem: String

    /// The category for this logger.
    public let category: String

    // MARK: - Initialization

    /// Creates a new ARCLogger with default console destination.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem identifier. Defaults to bundle identifier.
    ///   - category: The log category. Defaults to "Default".
    ///   - isProduction: Whether to treat as production. Defaults to `false`.
    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "ARCLogger",
        category: String = "Default",
        isProduction: Bool = false
    ) {
        self.subsystem = subsystem
        self.category = category
        self.isProduction = isProduction
        destinations = [ConsoleDestination()]
    }

    /// Creates a new ARCLogger with custom destinations.
    ///
    /// - Parameters:
    ///   - destinations: The log destinations to use.
    ///   - subsystem: The subsystem identifier. Defaults to bundle identifier.
    ///   - category: The log category. Defaults to "Default".
    ///   - isProduction: Whether to treat as production. Defaults to `false`.
    public init(
        destinations: [any LogDestination],
        subsystem: String = Bundle.main.bundleIdentifier ?? "ARCLogger",
        category: String = "Default",
        isProduction: Bool = false
    ) {
        self.destinations = destinations
        self.subsystem = subsystem
        self.category = category
        self.isProduction = isProduction
    }

    // MARK: - Logger

    public func log(
        _ message: String,
        level: LogLevel,
        metadata: [String: LogValue],
        file: String,
        function: String,
        line: Int
    ) {
        let entry = LogEntry(
            message: message,
            level: level,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )

        for destination in destinations {
            destination.write(entry, isProduction: isProduction)
        }
    }
}

// MARK: - Shared Instance

extension ARCLogger {
    /// A shared logger instance for convenience.
    ///
    /// This provides a global access point for simple logging needs.
    /// For more complex scenarios, create your own ARCLogger instance
    /// with custom configuration.
    ///
    /// ```swift
    /// ARCLogger.shared.info("Application started")
    /// ```
    public static let shared = ARCLogger()
}
