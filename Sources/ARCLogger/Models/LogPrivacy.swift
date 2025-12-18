// LogPrivacy.swift
// ARCLogger
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation

/// Specifies the privacy level for logged values.
///
/// Privacy levels control how sensitive data appears in logs:
/// - `public`: Value is always visible in logs
/// - `private`: Value is redacted in production logs
/// - `sensitive`: Value is always redacted
///
/// ## Example
///
/// ```swift
/// logger.info("User logged in", metadata: [
///     "userId": .public("12345"),
///     "email": .private("user@example.com"),
///     "password": .sensitive("***")
/// ])
/// ```
public enum LogPrivacy: Sendable, Equatable {
    /// The value is always visible in logs.
    ///
    /// Use for non-sensitive information that can be safely logged.
    case `public`

    /// The value is redacted in production builds.
    ///
    /// Use for personally identifiable information (PII) that should
    /// be visible during development but hidden in production.
    case `private`

    /// The value is always redacted.
    ///
    /// Use for highly sensitive data like passwords, tokens, or secrets.
    case sensitive
}

/// A value with associated privacy level for logging.
///
/// Wraps any value with privacy metadata to control how it appears in logs.
///
/// ## Example
///
/// ```swift
/// let publicValue = LogValue.public("visible")
/// let privateValue = LogValue.private("hidden in production")
/// let sensitiveValue = LogValue.sensitive("always hidden")
/// ```
public struct LogValue: Sendable, CustomStringConvertible {
    /// The underlying string value.
    public let value: String

    /// The privacy level for this value.
    public let privacy: LogPrivacy

    /// Creates a log value with the specified privacy level.
    ///
    /// - Parameters:
    ///   - value: The string value to log.
    ///   - privacy: The privacy level for this value.
    public init(_ value: String, privacy: LogPrivacy) {
        self.value = value
        self.privacy = privacy
    }

    /// Creates a public log value that is always visible.
    ///
    /// - Parameter value: The value to log.
    /// - Returns: A log value with public privacy.
    public static func `public`(_ value: String) -> LogValue {
        LogValue(value, privacy: .public)
    }

    /// Creates a private log value that is redacted in production.
    ///
    /// - Parameter value: The value to log.
    /// - Returns: A log value with private privacy.
    public static func `private`(_ value: String) -> LogValue {
        LogValue(value, privacy: .private)
    }

    /// Creates a sensitive log value that is always redacted.
    ///
    /// - Parameter value: The value to log.
    /// - Returns: A log value with sensitive privacy.
    public static func sensitive(_ value: String) -> LogValue {
        LogValue(value, privacy: .sensitive)
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        value
    }

    /// Returns the redacted value based on privacy level and environment.
    ///
    /// - Parameter isProduction: Whether the environment is production.
    /// - Returns: The value or a redacted placeholder.
    public func redacted(isProduction: Bool) -> String {
        switch privacy {
        case .public:
            value
        case .private:
            isProduction ? "<private>" : value
        case .sensitive:
            "<sensitive>"
        }
    }
}
