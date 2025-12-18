# Changelog

All notable changes to ARCLogger will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-01-01

### Added

- **Core Logging API**
  - `ARCLogger` struct with configurable destinations
  - `Logger` protocol for custom implementations
  - Shared instance for convenience (`ARCLogger.shared`)

- **Log Levels**
  - `LogLevel` enum with debug, info, warning, error, and critical levels
  - Comparable conformance for level filtering
  - Emoji representations for visual distinction

- **Privacy-Conscious Logging**
  - `LogPrivacy` enum for public, private, and sensitive data
  - `LogValue` struct for values with privacy levels
  - Automatic redaction in production environments

- **Structured Logging**
  - `LogEntry` struct with message, level, metadata, and source location
  - Metadata support with privacy-aware values
  - Timestamp and source file/line tracking

- **Log Destinations**
  - `LogDestination` protocol for custom outputs
  - `ConsoleDestination` with configurable formatting
  - Support for multiple concurrent destinations

- **Swift 6 Support**
  - Full `Sendable` conformance for concurrency safety
  - Strict concurrency mode enabled
  - Thread-safe by design

- **Documentation**
  - DocC documentation for all public APIs
  - Comprehensive README with usage examples
  - CLAUDE.md for AI agent context

- **Quality Assurance**
  - ARCDevTools integration (SwiftLint, SwiftFormat)
  - Comprehensive test suite with 100% coverage target
  - GitHub Actions CI/CD workflows

### Platforms

- iOS 17.0+
- macOS 14.0+
- watchOS 10.0+
- tvOS 17.0+

### Dependencies

- None (zero external dependencies)
