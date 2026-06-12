// JSONLinesDestination.swift
// ARCLogger
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under PolyForm Noncommercial 1.0.0

import Foundation

/// A log destination that emits one JSON object per line.
///
/// `JSONLinesDestination` writes each ``LogEntry`` as a newline-delimited
/// JSON record (NDJSON / JSON Lines). This format is consumed natively by
/// log scrapers, CI pipelines, observability tools, and custom MCP servers
/// that need structured access to ARCLogger output without parsing the
/// composed `os.Logger` message.
///
/// ## Schema
///
/// Each record has the following keys (stable, sorted alphabetically):
///
/// ```json
/// {
///   "category": "HTTP",
///   "file": "NetworkClient.swift",
///   "function": "send(_:)",
///   "level": "INFO",
///   "line": 42,
///   "message": "Request completed",
///   "metadata": {
///     "statusCode": { "privacy": "public", "value": "200" },
///     "userId":     { "privacy": "private", "value": "<private>" }
///   },
///   "subsystem": "com.myapp.Networking",
///   "timestamp": "2026-06-11T15:30:00.123Z"
/// }
/// ```
///
/// Privacy is applied **before** encoding:
/// - `.public` values are always emitted as-is.
/// - `.private` values are replaced with `<private>` when
///   `isProduction == true`.
/// - `.sensitive` values are always replaced with `<sensitive>`.
///
/// ## Example
///
/// ```swift
/// // Write to a file handle (e.g. a log file you opened):
/// let handle = try FileHandle(forWritingTo: logURL)
/// let json = JSONLinesDestination(handle: handle)
///
/// // Or sink to any closure (e.g. forward to a remote pipeline):
/// let json = JSONLinesDestination { data in
///     remoteLogShipper.send(data)
/// }
///
/// let logger = ARCLogger(destinations: [ConsoleDestination(), json])
/// ```
public struct JSONLinesDestination: LogDestination {
    /// The minimum log level to output.
    public let minimumLevel: LogLevel

    private let sink: @Sendable (Data) -> Void
    private let encoder: JSONEncoder

    /// Creates a destination that forwards each encoded record to a sink closure.
    ///
    /// - Parameters:
    ///   - minimumLevel: Minimum level to emit. Defaults to `.debug`.
    ///   - sink: Closure invoked with the encoded NDJSON bytes for each entry
    ///     (one JSON object followed by a `\n` newline).
    public init(minimumLevel: LogLevel = .debug,
                sink: @escaping @Sendable (Data) -> Void) {
        self.minimumLevel = minimumLevel
        self.sink = sink
        encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
    }

    /// Creates a destination that writes each encoded record to a `FileHandle`.
    ///
    /// Writes are synchronized internally; the same destination may be used
    /// from multiple threads or actors. The caller retains ownership of the
    /// handle and is responsible for closing it.
    ///
    /// - Parameters:
    ///   - handle: Destination handle (file, pipe, or `FileHandle.standardError`).
    ///   - minimumLevel: Minimum level to emit. Defaults to `.debug`.
    public init(handle: FileHandle, minimumLevel: LogLevel = .debug) {
        let lock = NSLock()
        self.init(minimumLevel: minimumLevel) { data in
            lock.lock()
            defer { lock.unlock() }
            try? handle.write(contentsOf: data)
        }
    }

    // MARK: - LogDestination

    public func write(_ entry: LogEntry, isProduction: Bool) {
        guard entry.level >= minimumLevel else { return }

        let payload = Payload(entry: entry, isProduction: isProduction)
        guard var data = try? encoder.encode(payload) else { return }
        data.append(0x0A) // '\n' — NDJSON record terminator
        sink(data)
    }
}

// MARK: - Encoded payload

extension JSONLinesDestination {
    /// Privacy-aware DTO. Encoding mirrors the public `LogEntry` shape but
    /// rewrites metadata values through ``LogValue/redacted(isProduction:)``
    /// so `.private`/`.sensitive` values never leak into the NDJSON stream.
    private struct Payload: Encodable {
        let message: String
        let level: String
        let metadata: [String: EncodedValue]
        let timestamp: Date
        let subsystem: String
        let category: String
        let file: String
        let function: String
        let line: Int

        init(entry: LogEntry, isProduction: Bool) {
            message = entry.message
            level = entry.level.description
            metadata = entry.metadata.mapValues { value in
                EncodedValue(privacy: value.privacy,
                             value: value.redacted(isProduction: isProduction))
            }
            timestamp = entry.timestamp
            subsystem = entry.subsystem
            category = entry.category
            file = entry.fileName
            function = entry.function
            line = entry.line
        }
    }

    private struct EncodedValue: Encodable {
        let privacy: LogPrivacy
        let value: String
    }
}
