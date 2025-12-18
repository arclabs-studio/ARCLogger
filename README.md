# ARCLogger

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%2B%20%7C%20macOS%2014%2B%20%7C%20watchOS%2010%2B%20%7C%20tvOS%2017%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)

**A privacy-conscious, structured logging framework for Swift applications.**

Privacy-first logging • Multiple destinations • Structured metadata • Thread-safe • Swift 6 ready

---

## Overview

ARCLogger is a lightweight, privacy-conscious logging framework designed for Swift applications. It provides structured logging with automatic privacy redaction, making it safe to use in production environments where sensitive data must be protected.

ARCLogger is part of the ARC Labs infrastructure packages and serves as a foundational dependency for other ARC packages. It has zero external dependencies and is built entirely on Apple frameworks.

### Key Features

- **Privacy-Conscious Logging** - Automatic redaction of sensitive data in production
- **Structured Metadata** - Add contextual data to logs for better debugging
- **Multiple Destinations** - Console, file, or custom destinations
- **Thread-Safe** - Safe to use from any thread or actor
- **Swift 6 Ready** - Full Sendable conformance and strict concurrency
- **Zero Dependencies** - Built entirely on Foundation

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

### Custom Destinations

Create custom log destinations for files, analytics, or remote services:

```swift
struct FileDestination: LogDestination {
    let fileURL: URL
    var minimumLevel: LogLevel = .info

    func write(_ entry: LogEntry, isProduction: Bool) {
        let message = "[\(entry.level)] \(entry.message)"
        // Write to file...
    }
}

// Use custom destination
let logger = ARCLogger(
    destinations: [ConsoleDestination(), FileDestination(fileURL: logFile)],
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
│   │       └── ConsoleDestination.swift
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

**Sample output:**

```
[2025-12-18 10:30:00.123] ℹ️ [INFO] User authenticated {userId=USR-12345, email=<private>, token=<sensitive>}
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

## License

MIT License - see [LICENSE](LICENSE) for details.

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
