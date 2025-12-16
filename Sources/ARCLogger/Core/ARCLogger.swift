import Foundation

/// Main logging facade for ARC Labs Studio packages.
///
/// Provides a unified interface for logging across all packages
/// with support for multiple destinations and structured context.
///
/// ## Usage
///
/// ```swift
/// let logger = ARCLogger(
///     category: "Network",
///     subsystem: "com.arclabs-studio.arcnetworking"
/// )
///
/// logger.debug("Starting request", metadata: ["url": "https://api.example.com"])
/// logger.error("Request failed", error: someError)
/// ```
public struct ARCLogger: Sendable {
    private let context: LogContext
    private let destinations: [LogDestination]

    public init(
        category: String,
        subsystem: String,
        destinations: [LogDestination]? = nil
    ) {
        self.context = LogContext(category: category, subsystem: subsystem)

        // Default destinations if none provided
        if let destinations = destinations {
            self.destinations = destinations
        } else {
            #if DEBUG
            self.destinations = [
                ConsoleDestination(),
                OSLogDestination(subsystem: subsystem, category: category)
            ]
            #else
            self.destinations = [
                OSLogDestination(subsystem: subsystem, category: category, minimumLevel: .warning)
            ]
            #endif
        }
    }

    // MARK: - Public Methods

    public func debug(
        _ message: String,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    public func info(
        _ message: String,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    public func warning(
        _ message: String,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .warning, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    public func error(
        _ message: String,
        error: Error? = nil,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var enrichedMetadata = metadata
        if let error = error {
            enrichedMetadata["error"] = error.localizedDescription
        }

        log(level: .error, message: message, metadata: enrichedMetadata, file: file, function: function, line: line)
    }

    public func critical(
        _ message: String,
        error: Error? = nil,
        metadata: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var enrichedMetadata = metadata
        if let error = error {
            enrichedMetadata["error"] = error.localizedDescription
        }

        log(level: .critical, message: message, metadata: enrichedMetadata, file: file, function: function, line: line)
    }

    // MARK: - Private Methods

    private func log(
        level: LogLevel,
        message: String,
        metadata: [String: String],
        file: String,
        function: String,
        line: Int
    ) {
        let enrichedContext = LogContext(
            category: context.category,
            subsystem: context.subsystem,
            file: file,
            function: function,
            line: line,
            metadata: metadata
        )

        for destination in destinations {
            destination.write(level: level, message: message, context: enrichedContext)
        }
    }
}
