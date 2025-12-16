import Foundation

/// A destination where log messages can be sent.
///
/// Conform to this protocol to create custom log outputs
/// (console, file, remote service, etc.).
public protocol LogDestination: Sendable {
    /// Minimum level of messages this destination accepts.
    var minimumLevel: LogLevel { get }

    /// Writes a log message to this destination.
    ///
    /// - Parameters:
    ///   - level: Severity level
    ///   - message: The message to log
    ///   - context: Contextual information
    func write(level: LogLevel, message: String, context: LogContext)
}
