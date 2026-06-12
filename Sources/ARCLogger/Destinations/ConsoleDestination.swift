// ConsoleDestination.swift
// ARCLogger
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Foundation
#if canImport(os)
import os
#endif

/// A log destination that writes to Apple's unified logging system.
///
/// `ConsoleDestination` routes messages through `os.Logger`, making them
/// visible in Console.app, `log stream`, and Xcode's debug console —
/// including when the app is launched detached from Xcode.
///
/// Privacy is applied natively by the OS using the metadata's `LogPrivacy` level:
/// - `.public` values are always visible.
/// - `.private` values are redacted to `<private>` in release builds.
/// - `.sensitive` values are always replaced with a hash.
///
/// For command-line tools or demo executables that also need `stdout` output,
/// set `mirrorsToStdout: true`. The formatting options (`includeTimestamp`,
/// `useEmoji`, `includeSourceLocation`) only affect the stdout mirror and are
/// ignored when `mirrorsToStdout` is `false`.
///
/// ## Example
///
/// ```swift
/// // Default — unified log only
/// let console = ConsoleDestination()
///
/// // With stdout mirror (e.g. CLI tools, demo apps)
/// let console = ConsoleDestination(mirrorsToStdout: true)
/// ```
public struct ConsoleDestination: LogDestination {
    /// The minimum log level to output.
    public let minimumLevel: LogLevel

    /// Whether to mirror output to stdout via `print()` in addition to the unified log.
    ///
    /// Defaults to `false`. Set to `true` for command-line tools or demo apps that
    /// need visible terminal output. The formatting options (`includeTimestamp`,
    /// `useEmoji`, `includeSourceLocation`) only affect this mirror.
    public let mirrorsToStdout: Bool

    /// Whether to include timestamps in the stdout mirror output.
    public let includeTimestamp: Bool

    /// Whether to include source location in the stdout mirror output.
    public let includeSourceLocation: Bool

    /// Whether to use emoji prefixes in the stdout mirror output.
    public let useEmoji: Bool

    private let dateFormatter: DateFormatter

    /// Creates a new console destination.
    ///
    /// - Parameters:
    ///   - minimumLevel: Minimum level to log. Defaults to `.debug`.
    ///   - mirrorsToStdout: Also print to stdout. Defaults to `false`.
    ///   - includeTimestamp: Include timestamp in stdout mirror. Defaults to `true`.
    ///   - includeSourceLocation: Include file/line in stdout mirror. Defaults to `false`.
    ///   - useEmoji: Use emoji prefixes in stdout mirror. Defaults to `true`.
    public init(minimumLevel: LogLevel = .debug,
                mirrorsToStdout: Bool = false,
                includeTimestamp: Bool = true,
                includeSourceLocation: Bool = false,
                useEmoji: Bool = true) {
        self.minimumLevel = minimumLevel
        self.mirrorsToStdout = mirrorsToStdout
        self.includeTimestamp = includeTimestamp
        self.includeSourceLocation = includeSourceLocation
        self.useEmoji = useEmoji
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }

    // MARK: - LogDestination

    public func write(_ entry: LogEntry, isProduction: Bool) {
        guard entry.level >= minimumLevel else { return }

        #if canImport(os)
        let subsystem = entry.subsystem.isEmpty ? "ARCLogger" : entry.subsystem
        let category = entry.category.isEmpty ? "Default" : entry.category
        let osLogger = os.Logger(subsystem: subsystem, category: category)

        // Single pass: partition metadata by privacy level so each bucket can
        // use the correct compile-time OSLog interpolation annotation.
        // OSLogMessage templates are compile-time constants — this bounded
        // three-segment template is the only way to emit dynamic metadata with
        // native OSLog privacy semantics.
        var publicParts: [String] = []
        var privateParts: [String] = []
        var sensitiveParts: [String] = []

        for (key, value) in entry.metadata {
            let pair = "\(key)=\(value.value)"
            switch value.privacy {
            case .public: publicParts.append(pair)
            case .private: privateParts.append(pair)
            case .sensitive: sensitiveParts.append(pair)
            }
        }

        let publicMeta = publicParts.sorted().joined(separator: ", ")
        let privateMeta = privateParts.sorted().joined(separator: ", ")
        let sensitiveMeta = sensitiveParts.sorted().joined(separator: ", ")
        let sourceLocation = "[\(entry.fileName):\(entry.line)]"

        // The main message is developer-provided and must be explicitly marked
        // .public; otherwise the OS redacts all strings by default in production.
        // Four fixed interpolation segments: source location, message, public/
        // private/sensitive metadata buckets. Source paths and line numbers are
        // non-sensitive build artifacts, so they ride in the .public stream
        // alongside the message — this is what makes `xclog` / Console.app /
        // `log stream` show "[File.swift:42]" for every entry without a stdout
        // mirror. OSLogMessage templates are compile-time constants so this
        // bounded form is the only way to emit dynamic metadata with native
        // OSLog privacy semantics. Empty buckets produce harmless trailing
        // spaces. Multiline literal with \ continuation produces the same
        // single-line OSLogMessage while keeping each source line under the
        // 120-char limit.
        osLogger.log(level: entry.level.osLogType,
                     """
                     \(sourceLocation, privacy: .public) \
                     \(entry.message, privacy: .public) \
                     \(publicMeta, privacy: .public) \
                     \(privateMeta, privacy: .private) \
                     \(sensitiveMeta, privacy: .sensitive(mask: .hash))
                     """)
        #endif

        if mirrorsToStdout {
            print(format(entry, isProduction: isProduction))
        }
    }
}

// MARK: - Private

extension ConsoleDestination {
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
