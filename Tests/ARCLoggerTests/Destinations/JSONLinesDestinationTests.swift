// JSONLinesDestinationTests.swift
// ARCLoggerTests
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under PolyForm Noncommercial 1.0.0

import Foundation
import Testing
@testable import ARCLogger

struct JSONLinesDestinationTests {
    // MARK: - Helpers

    private final class Capture: @unchecked Sendable {
        private let lock = NSLock()
        private var lines: [String] = []

        func append(_ data: Data) {
            lock.lock()
            defer { lock.unlock() }
            if let line = String(data: data, encoding: .utf8) {
                lines.append(line)
            }
        }

        var collected: [String] {
            lock.lock()
            defer { lock.unlock() }
            return lines
        }
    }

    private func makeSUT(minimumLevel: LogLevel = .debug) -> (JSONLinesDestination, Capture) {
        let capture = Capture()
        let destination = JSONLinesDestination(minimumLevel: minimumLevel) { data in
            capture.append(data)
        }
        return (destination, capture)
    }

    private func decode(_ line: String) throws -> [String: Any] {
        let trimmed = line.trimmingCharacters(in: .newlines)
        let data = Data(trimmed.utf8)
        let json = try JSONSerialization.jsonObject(with: data)
        guard let object = json as? [String: Any] else {
            throw DecodeError.notAnObject
        }
        return object
    }

    private enum DecodeError: Error { case notAnObject, missingKey }

    // MARK: - Schema

    @Test("Emits one NDJSON record per entry terminated by newline") func emitsNdjson() throws {
        let (sut, capture) = makeSUT()
        let entry = LogEntry(message: "Hi",
                             level: .info,
                             metadata: [:],
                             subsystem: "com.test",
                             category: "Net")

        sut.write(entry, isProduction: false)

        #expect(capture.collected.count == 1)
        let line = try #require(capture.collected.first)
        #expect(line.hasSuffix("\n"))
    }

    @Test("Encodes all top-level keys") func encodesTopLevelKeys() throws {
        let (sut, capture) = makeSUT()
        let entry = LogEntry(message: "Hello",
                             level: .warning,
                             metadata: [:],
                             subsystem: "com.test.app",
                             category: "HTTP",
                             file: "/abs/path/NetworkClient.swift",
                             function: "send(_:)",
                             line: 42)

        sut.write(entry, isProduction: false)

        let object = try decode(#require(capture.collected.first))

        #expect(object["message"] as? String == "Hello")
        #expect(object["level"] as? String == "WARNING")
        #expect(object["subsystem"] as? String == "com.test.app")
        #expect(object["category"] as? String == "HTTP")
        #expect(object["file"] as? String == "NetworkClient.swift")
        #expect(object["function"] as? String == "send(_:)")
        #expect(object["line"] as? Int == 42)
        #expect(object["timestamp"] is String)
        #expect(object["metadata"] is [String: Any])
    }

    // MARK: - Privacy

    @Test("Public metadata is emitted as-is in development and production") func publicAlwaysVisible() throws {
        let (sut, capture) = makeSUT()
        let entry = LogEntry(message: "m",
                             level: .info,
                             metadata: ["id": .public("123")])

        sut.write(entry, isProduction: false)
        sut.write(entry, isProduction: true)

        for line in capture.collected {
            let object = try decode(line)
            let metadata = try #require(object["metadata"] as? [String: [String: String]])
            #expect(metadata["id"]?["value"] == "123")
            #expect(metadata["id"]?["privacy"] == "public")
        }
    }

    @Test("Private metadata is redacted only in production") func privateRedactedInProduction() throws {
        let (sut, capture) = makeSUT()
        let entry = LogEntry(message: "m",
                             level: .info,
                             metadata: ["email": .private("user@test.com")])

        sut.write(entry, isProduction: false)
        sut.write(entry, isProduction: true)

        #expect(capture.collected.count == 2)
        let dev = try decode(capture.collected[0])
        let prod = try decode(capture.collected[1])

        let devMeta = try #require(dev["metadata"] as? [String: [String: String]])
        let prodMeta = try #require(prod["metadata"] as? [String: [String: String]])

        #expect(devMeta["email"]?["value"] == "user@test.com")
        #expect(prodMeta["email"]?["value"] == "<private>")
    }

    @Test("Sensitive metadata is always redacted") func sensitiveAlwaysRedacted() throws {
        let (sut, capture) = makeSUT()
        let entry = LogEntry(message: "m",
                             level: .info,
                             metadata: ["token": .sensitive("abc-123")])

        sut.write(entry, isProduction: false)
        sut.write(entry, isProduction: true)

        for line in capture.collected {
            let object = try decode(line)
            let metadata = try #require(object["metadata"] as? [String: [String: String]])
            #expect(metadata["token"]?["value"] == "<sensitive>")
        }
    }

    // MARK: - Filtering

    @Test("Entries below minimumLevel are dropped") func respectsMinimumLevel() {
        let (sut, capture) = makeSUT(minimumLevel: .warning)
        let debugEntry = LogEntry(message: "d", level: .debug)
        let warningEntry = LogEntry(message: "w", level: .warning)

        sut.write(debugEntry, isProduction: false)
        sut.write(warningEntry, isProduction: false)

        #expect(capture.collected.count == 1)
    }

    // MARK: - FileHandle variant

    @Test("FileHandle initializer writes valid NDJSON to disk") func fileHandleWritesNdjson() throws {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("arclogger-jsonl-\(UUID().uuidString).log")
        FileManager.default.createFile(atPath: tempURL.path, contents: nil)
        let handle = try FileHandle(forWritingTo: tempURL)
        defer {
            try? handle.close()
            try? FileManager.default.removeItem(at: tempURL)
        }

        let destination = JSONLinesDestination(handle: handle)
        destination.write(LogEntry(message: "first", level: .info), isProduction: false)
        destination.write(LogEntry(message: "second", level: .error), isProduction: false)

        try handle.synchronize()
        let written = try String(contentsOf: tempURL, encoding: .utf8)
        let lines = written.split(separator: "\n", omittingEmptySubsequences: true)

        #expect(lines.count == 2)
        let first = try JSONSerialization.jsonObject(with: Data(lines[0].utf8)) as? [String: Any]
        #expect(first?["message"] as? String == "first")
        #expect(first?["level"] as? String == "INFO")
    }
}
