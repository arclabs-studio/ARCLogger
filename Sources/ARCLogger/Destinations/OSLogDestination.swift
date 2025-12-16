import Foundation
import os

/// Logs messages using Apple's unified logging system (os.Logger).
///
/// Provides structured logging visible in Console.app and Xcode.
public struct OSLogDestination: LogDestination {
    public let minimumLevel: LogLevel
    private let logger: Logger

    public init(
        subsystem: String,
        category: String,
        minimumLevel: LogLevel = .info
    ) {
        self.minimumLevel = minimumLevel
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func write(level: LogLevel, message: String, context: LogContext) {
        guard level >= minimumLevel else { return }

        let enrichedMessage = "\(level.emoji) \(message)"

        switch level {
        case .debug:
            logger.debug("\(enrichedMessage, privacy: .public)")
        case .info:
            logger.info("\(enrichedMessage, privacy: .public)")
        case .warning:
            logger.warning("\(enrichedMessage, privacy: .public)")
        case .error:
            logger.error("\(enrichedMessage, privacy: .public)")
        case .critical:
            logger.critical("\(enrichedMessage, privacy: .public)")
        }
    }
}
