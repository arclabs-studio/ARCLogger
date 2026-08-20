# Changelog

All notable changes to ARCLogger will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-20

First public release of **ARCLogger**.

ARC Labs Studio re-baselined every package at `1.0.0` for its first product launch. The pre-launch version history (0.1.0 → 1.0.0) never corresponded to a release the studio stood behind; those tags and GitHub Releases have been removed and the notes are preserved below under [Pre-1.0 history](#pre-10-history-untagged).

### Added

- **`INTERNAL-USE.md`** — documents ARC Labs Studio's self-grant for commercial use of its own products under the new licence.

- **`ConsoleDestination.mirrorsToStdout`** — opt-in flag (default `false`) that additionally prints
  formatted output to stdout. Set to `true` for CLI tools or demo executables that need terminal output.
- **`LogEntry.subsystem` and `LogEntry.category`** — new fields (defaulted to `""`) that thread
  `ARCLogger`'s subsystem/category through to destinations. Custom `LogDestination` implementations
  receive these automatically with no source changes required.
- **Native OSLog privacy semantics** — `.public` values are always visible; `.private` values are
  redacted to `<private>` by the OS in release builds; `.sensitive` values are always hash-masked.
  Redaction is now enforced at the OS level, not in application code.

### Fixed

- **ConsoleDestination now routes through Apple's unified logging system (`os.Logger`)** instead of `print()`.
  Previously all log output went to stdout only, making it invisible to Console.app, `log stream`,
  and apps launched detached from Xcode. Logs now appear in every standard Apple logging channel.

### Viewing Logs via the Unified Log

After this change, every ARCLogger call is observable via:

```bash
log stream --level debug --predicate 'subsystem CONTAINS "com.yourapp"'
```

or in Console.app by filtering on your app's subsystem/category.

### Changed

- **License** — relicensed from MIT to [PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0). Source-available and free for non-commercial use; commercial use requires a separate licence from ARC Labs Studio. ARC Labs Studio's own products are covered by an internal grant — see `INTERNAL-USE.md`.

---

## Pre-1.0 history (untagged)

Everything below predates the 1.0.0 baseline. The version numbers are retained for traceability only — no tag or release exists for any of them.

### [1.0.0] - 2025-01-01

#### Added

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

#### Platforms

- iOS 17.0+
- macOS 14.0+
- watchOS 10.0+
- tvOS 17.0+

#### Dependencies

- None (zero external dependencies)

---

[1.0.0]: https://github.com/arclabs-studio/ARCLogger/releases/tag/v1.0.0
