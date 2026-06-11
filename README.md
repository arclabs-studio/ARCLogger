# ARCLogger

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%2B%20%7C%20macOS%2014%2B%20%7C%20watchOS%2010%2B%20%7C%20tvOS%2017%2B-blue.svg)
![License](https://img.shields.io/badge/License-PolyForm%20Noncommercial%201.0.0-orange.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)

**A privacy-conscious, structured logging framework for Swift applications.**

Privacy-first logging • Multiple destinations • Structured metadata • Thread-safe • Swift 6 ready

---

## Overview

ARCLogger is a lightweight, privacy-conscious logging framework designed for Swift applications. It provides structured logging with automatic privacy redaction, making it safe to use in production environments where sensitive data must be protected.

ARCLogger is part of the ARC Labs infrastructure packages and serves as a foundational dependency for other ARC packages. It has zero external dependencies and is built entirely on Apple frameworks.

### Key Features

- **Privacy-Conscious Logging** - Automatic redaction of sensitive data in production
- **Unified Logging** - Routes through Apple's `os.Logger`; visible in Console.app, `log stream`, and Xcode
- **Structured Metadata** - Add contextual data to logs for better debugging
- **Multiple Destinations** - Console, file, or custom destinations
- **Thread-Safe** - Safe to use from any thread or actor
- **Swift 6 Ready** - Full Sendable conformance and strict concurrency
- **Zero Dependencies** - Built entirely on Apple frameworks

---

## Requirements

- **Swift:** 6.0+
- **Platforms:** iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 17.0+
- **Xcode:** 16.0+

---

## Installation

### Swift Package Manager

#### For Swift Packages

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCLogger", from: "1.0.0")
]
```

Then add `ARCLogger` to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ARCLogger"]
)
```

#### For Xcode Projects

1. **File → Add Package Dependencies**
2. Enter: `https://github.com/arclabs-studio/ARCLogger`
3. Select version: `1.0.0` or later
4. Add to your target

---

## Usage

### Quick Start

```swift
import ARCLogger

// Use the shared instance for simple logging
ARCLogger.shared.info("Application started")

// Or create your own logger
let logger = ARCLogger()

// Log at different levels
logger.debug("Debugging information")
logger.info("Informational message")
logger.warning("Warning: something unexpected")
logger.error("Error occurred")
logger.critical("Critical failure!")
```

### Privacy-Conscious Logging

ARCLogger automatically redacts sensitive data based on privacy levels:

```swift
logger.info("User authenticated", metadata: [
    "userId": .public("12345"),           // Always visible
    "email": .private("user@test.com"),   // Hidden in production
    "token": .sensitive("abc123xyz")      // Always hidden
])

// Development output:
// [INFO] User authenticated {userId=12345, email=user@test.com, token=<sensitive>}

// Production output:
// [INFO] User authenticated {userId=12345, email=<private>, token=<sensitive>}
```

### Privacy Levels

| Level | Development | Production | Use Case |
|-------|-------------|------------|----------|
| `.public` | Visible | Visible | Non-sensitive data (IDs, counts) |
| `.private` | Visible | Redacted | PII (emails, names) |
| `.sensitive` | Redacted | Redacted | Secrets (tokens, passwords) |

### Type-Scoped Loggers

For the common pattern of scoping a logger to a single type, use the
`init(for:)` convenience initializer. The category becomes
`String(describing: type)`, which makes filtering trivial in Console.app,
`log stream`, or `xclog`:

```swift
final class NetworkClient {
    private let logger = ARCLogger(for: NetworkClient.self)
    // subsystem = bundle identifier, category = "NetworkClient"
}
```

```bash
# Stream only NetworkClient logs
log stream --predicate 'category == "NetworkClient"'
```

### Built-in Destinations

| Destination              | Output           | Use case                                       |
|--------------------------|------------------|------------------------------------------------|
| ``ConsoleDestination``   | `os.Logger`      | Console.app, `log stream`, `xclog`, Xcode      |
| ``JSONLinesDestination`` | NDJSON           | Log pipelines, CI scrapers, custom MCP servers |

`JSONLinesDestination` writes one privacy-aware JSON object per line:

```swift
// Stream to a file:
let handle = try FileHandle(forWritingTo: logURL)
let json = JSONLinesDestination(handle: handle)

// Or to any sink closure:
let json = JSONLinesDestination { data in
    remoteLogShipper.send(data)
}

let logger = ARCLogger(destinations: [ConsoleDestination(), json])
```

Each record contains `message`, `level`, `metadata`, `timestamp`,
`subsystem`, `category`, `file`, `function`, and `line`. `.private`
values are redacted to `<private>` in production; `.sensitive` values
are always `<sensitive>` — privacy is applied **before** encoding.

### Custom Destinations

Create custom log destinations for analytics, remote services, or other sinks:

```swift
struct AnalyticsDestination: LogDestination {
    var minimumLevel: LogLevel = .warning

    func write(_ entry: LogEntry, isProduction: Bool) {
        Analytics.track(level: entry.level, message: entry.message)
    }
}

let logger = ARCLogger(
    destinations: [ConsoleDestination(), AnalyticsDestination()],
    isProduction: true
)
```

### Log Levels

| Level | Emoji | Use Case |
|-------|-------|----------|
| `.debug` | 🔍 | Verbose debugging info |
| `.info` | ℹ️ | Routine operational messages |
| `.warning` | ⚠️ | Unexpected but recoverable |
| `.error` | ❌ | Errors that allow continued execution |
| `.critical` | 🔥 | Severe errors, potential termination |

### Custom Configuration

```swift
let logger = ARCLogger(
    destinations: [
        ConsoleDestination(
            minimumLevel: .info,
            // mirrorsToStdout: true  // uncomment for CLI tools / demo apps
            includeTimestamp: true,
            includeSourceLocation: true,
            useEmoji: true
        )
    ],
    subsystem: "com.myapp",
    category: "Networking",
    isProduction: true
)
```

### Viewing Logs via the Unified Log

`ConsoleDestination` routes through Apple's unified logging system (`os.Logger`). Logs are visible in
Console.app and via `log stream`:

```bash
# Stream logs from your app in real time
log stream --level debug --predicate 'subsystem CONTAINS "com.myapp"'

# Show historical logs
log show --last 1h --predicate 'subsystem CONTAINS "com.myapp"' --info --debug
```

For CLI tools or demo executables that also need stdout output, opt in with `mirrorsToStdout: true`:

```swift
ConsoleDestination(mirrorsToStdout: true)
```

Every unified-log entry is prefixed with `[File.swift:42]` (public source
location) so Console.app, `log stream`, and `xclog` show the call site without
needing the stdout mirror. `includeSourceLocation` only controls whether the
stdout mirror *also* prints it.

### Using ARCLogger with `xclog`

[`xclog`](https://github.com/arclabs-studio/axiom) — Axiom's simulator console
capture CLI — reads Apple's unified log and returns structured JSON. Because
`ConsoleDestination` already routes through `os.Logger`, every ARCLogger call
is captured by `xclog` with no extra setup.

```bash
# Discover the running app's bundle id
xclog list

# Capture 30s of logs filtered by subsystem + category
xclog launch com.yourapp.MyApp \
  --subsystem com.yourapp.MyApp \
  --category Networking \
  --timeout 30s \
  --max-lines 200
```

To filter cleanly, give ARCLogger a real subsystem and category — do **not**
rely on the `Bundle.main.bundleIdentifier` default when constructing loggers
from inside Swift packages (it falls back to `"ARCLogger"` in SPM/CLI
contexts):

```swift
let logger = ARCLogger(
    subsystem: "com.yourapp.MyApp.Networking",
    category: "HTTP"
)
```

#### Level mapping (important for `xclog --level` filtering)

`OSLogType` has no native `warning`, so ARCLogger maps levels as follows:

| ARCLogger level | `OSLogType` | `xclog`/Console.app level |
|-----------------|-------------|---------------------------|
| `.debug`        | `.debug`    | `debug`                   |
| `.info`         | `.info`     | `info`                    |
| `.warning`      | `.default`  | `default` (not `warning`) |
| `.error`        | `.error`    | `error`                   |
| `.critical`     | `.fault`    | `fault`                   |

When filtering warnings with `xclog`, use `--level default` (or higher).

#### `isProduction` vs OS redaction

The OS handles `.private` / `.sensitive` redaction in release builds
automatically — the `isProduction` flag on `ARCLogger` only affects how the
optional stdout mirror formats redacted values. Unified-log output is governed
by the build configuration, not by this flag.

---

## Project Structure

```
ARCLogger/
├── Sources/
│   ├── ARCLogger/
│   │   ├── Core/
│   │   │   └── ARCLogger.swift        # Main logger implementation
│   │   ├── Models/
│   │   │   ├── LogEntry.swift         # Structured log entry
│   │   │   ├── LogLevel.swift         # Log severity levels
│   │   │   └── LogPrivacy.swift       # Privacy levels and redaction
│   │   ├── Protocols/
│   │   │   ├── Logger.swift           # Logger protocol
│   │   │   └── LogDestination.swift   # Destination protocol
│   │   └── Destinations/
│   │       ├── ConsoleDestination.swift
│   │       └── JSONLinesDestination.swift
│   └── ARCLoggerDemo/
│       └── main.swift                 # Interactive demo
├── Tests/
│   └── ARCLoggerTests/
│       ├── Core/
│       ├── Models/
│       ├── Destinations/
│       └── Helpers/
└── ARCDevTools/                       # Submodule
```

---

## Testing

```bash
swift test
```

### Coverage

- **Target:** 100%
- **Minimum:** 80%

---

## Architecture

ARCLogger follows a protocol-first design with dependency injection:

- **Logger Protocol** - Defines the logging interface
- **LogDestination Protocol** - Extensible output destinations
- **Value Types** - Immutable structs for thread safety
- **Sendable Conformance** - Full Swift 6 concurrency support

For complete architecture guidelines, see [ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge).

---

## Development

### Prerequisites

```bash
# Install required tools
brew install swiftlint swiftformat
```

### Setup

```bash
# Clone the repository
git clone https://github.com/arclabs-studio/ARCLogger.git
cd ARCLogger

# Initialize submodules
git submodule update --init --recursive

# Build the project
swift build
```

### Run the Demo

ARCLogger includes an interactive demo that showcases all features:

```bash
swift run ARCLoggerDemo
```

The demo covers:
- Basic logging at all levels
- Privacy redaction (development vs production)
- Custom destination configuration
- Log level filtering
- Multiple destinations
- Practical authentication flow example

**Sample output** (stdout mirror):

```
[2025-12-18 10:30:00.123] ℹ️ [INFO] User authenticated {userId=USR-12345, email=<private>, token=<sensitive>}
```

The same entry is also emitted to the unified log, visible via:

```bash
log stream --level debug --predicate 'subsystem CONTAINS "arclogger"'
```

### Available Commands

```bash
make help          # Show all available commands
make lint          # Run SwiftLint
make format        # Preview formatting changes
make fix           # Apply SwiftFormat
make test          # Run tests
make clean         # Remove build artifacts
```

---

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `feature/your-feature`
3. Follow [ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge) standards
4. Ensure tests pass: `swift test`
5. Run quality checks: `make lint && make format`
6. Create a pull request

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add file logging destination
fix: resolve memory leak in console output
docs: update installation instructions
```

---

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** - Breaking changes
- **MINOR** - New features (backwards compatible)
- **PATCH** - Bug fixes (backwards compatible)

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## 📄 License

**PolyForm Noncommercial License 1.0.0** © 2025–2026 ARC Labs Studio.

Source-available. Free for non-commercial use (research, study, hobby, evaluation). **Commercial use requires a separate license** — contact `arclabs.studio@gmail.com`.

ARC Labs Studio's own commercial products are covered by an internal use grant — see [INTERNAL-USE.md](INTERNAL-USE.md).

See [LICENSE](LICENSE) for the full license text.

---

## Related Resources

- **[ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge)** - Development standards and guidelines
- **[ARCDevTools](https://github.com/arclabs-studio/ARCDevTools)** - Quality tooling and automation
- **[ARCDesignSystem](https://github.com/arclabs-studio/ARCDesignSystem)** - UI components and theming

---

<div align="center">

Made with 💛 by ARC Labs Studio

[**GitHub**](https://github.com/arclabs-studio) • [**Issues**](https://github.com/arclabs-studio/ARCLogger/issues)

</div>
