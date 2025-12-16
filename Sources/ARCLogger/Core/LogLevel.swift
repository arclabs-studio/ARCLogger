import Foundation

/// Severity levels for log messages.
///
/// Ordered from least to most severe to allow filtering.
public enum LogLevel: Int, Comparable, Sendable {
    /// Detailed information for debugging.
    case debug = 0

    /// General informational messages.
    case info = 1

    /// Warning messages for potentially problematic situations.
    case warning = 2

    /// Error messages for failures.
    case error = 3

    /// Critical failures requiring immediate attention.
    case critical = 4

    /// Emoji representation for console output.
    public var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🔥"
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
