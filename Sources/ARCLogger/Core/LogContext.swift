import Foundation

/// Contextual information attached to a log message.
///
/// Provides structured data that helps filter and analyze logs.
public struct LogContext: Sendable {
    /// Functional category (e.g., "Network", "Storage", "UI").
    public let category: String

    /// Subsystem identifier (reverse domain notation).
    public let subsystem: String

    /// Optional file where the log originated.
    public let file: String?

    /// Optional function where the log originated.
    public let function: String?

    /// Optional line number.
    public let line: Int?

    /// Additional custom metadata.
    public let metadata: [String: String]

    public init(
        category: String,
        subsystem: String,
        file: String? = nil,
        function: String? = nil,
        line: Int? = nil,
        metadata: [String: String] = [:]
    ) {
        self.category = category
        self.subsystem = subsystem
        self.file = file
        self.function = function
        self.line = line
        self.metadata = metadata
    }
}
