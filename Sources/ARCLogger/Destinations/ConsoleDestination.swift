import Foundation

/// Logs messages to the standard output (console).
///
/// Only active in DEBUG builds to avoid polluting production logs.
public struct ConsoleDestination: LogDestination {
    public let minimumLevel: LogLevel

    public init(minimumLevel: LogLevel = .debug) {
        self.minimumLevel = minimumLevel
    }

    public func write(level: LogLevel, message: String, context: LogContext) {
        #if DEBUG
        guard level >= minimumLevel else { return }

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let location = buildLocationString(context)

        print("""
        \(level.emoji) [\(context.category)] \(timestamp)
        \(message)\(location)
        """)
        #endif
    }

    private func buildLocationString(_ context: LogContext) -> String {
        var parts: [String] = []

        if let file = context.file {
            parts.append("📄 \((file as NSString).lastPathComponent)")
        }

        if let function = context.function {
            parts.append("⚙️ \(function)")
        }

        if let line = context.line {
            parts.append("📍 L\(line)")
        }

        return parts.isEmpty ? "" : "\n\(parts.joined(separator: " | "))"
    }
}
