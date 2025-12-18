# ARCLogger - AI Agent Context

## Package Overview

ARCLogger is a privacy-conscious, structured logging framework for Swift applications. It's a foundational package in the ARC Labs ecosystem with zero external dependencies.

## Key Concepts

### Privacy Levels

- `.public` - Always visible (IDs, counts, non-sensitive data)
- `.private` - Visible in development, redacted in production (PII)
- `.sensitive` - Always redacted (passwords, tokens, secrets)

### Log Levels

Ordered from least to most severe:
1. `.debug` - Detailed debugging info
2. `.info` - Routine operations
3. `.warning` - Unexpected but recoverable
4. `.error` - Errors allowing continued execution
5. `.critical` - Severe errors, potential termination

### Architecture

```
Logger (protocol)
    └── ARCLogger (struct, Sendable)
            └── LogDestination (protocol)
                    └── ConsoleDestination (struct, Sendable)

LogEntry (struct, Sendable)
    ├── message: String
    ├── level: LogLevel
    ├── metadata: [String: LogValue]
    ├── timestamp: Date
    └── source location (file, function, line)

LogValue (struct, Sendable)
    ├── value: String
    └── privacy: LogPrivacy
```

## Common Patterns

### Basic Logging

```swift
let logger = ARCLogger()
logger.info("Operation completed")
```

### With Metadata

```swift
logger.info("User action", metadata: [
    "userId": .public("123"),
    "action": .public("login")
])
```

### Production Configuration

```swift
let logger = ARCLogger(
    destinations: [ConsoleDestination(minimumLevel: .warning)],
    isProduction: true
)
```

### Custom Destination

```swift
struct MyDestination: LogDestination {
    var minimumLevel: LogLevel = .debug

    func write(_ entry: LogEntry, isProduction: Bool) {
        // Custom handling
    }
}
```

## File Organization

```
Sources/ARCLogger/
├── Core/
│   └── ARCLogger.swift          # Main logger implementation
├── Models/
│   ├── LogEntry.swift           # Structured log entry
│   ├── LogLevel.swift           # Severity levels enum
│   └── LogPrivacy.swift         # Privacy levels + LogValue
├── Protocols/
│   ├── Logger.swift             # Logger protocol + convenience methods
│   └── LogDestination.swift     # Destination protocol
└── Destinations/
    └── ConsoleDestination.swift # Console output implementation

Tests/ARCLoggerTests/
├── Core/
│   └── ARCLoggerTests.swift
├── Models/
│   ├── LogEntryTests.swift
│   ├── LogLevelTests.swift
│   └── LogPrivacyTests.swift
├── Destinations/
│   └── ConsoleDestinationTests.swift
└── Helpers/
    ├── MockLogDestination.swift
    └── LogTestHelpers.swift
```

## Design Decisions

1. **Structs over Classes** - Value semantics for thread safety
2. **Protocol-first** - `Logger` and `LogDestination` protocols for extensibility
3. **Sendable everywhere** - Full Swift 6 concurrency support
4. **No singletons** - `shared` is just a convenience, not required
5. **Zero dependencies** - Only Foundation, maximally portable

## Testing

Tests use Swift Testing framework (`@Test`, `@Suite`).

```bash
swift test
```

Coverage target: 100%

## Quality Tools

- SwiftLint (`.swiftlint.yml`)
- SwiftFormat (`.swiftformat`)
- Git hooks for pre-commit/pre-push

## Limitations

- No file logging built-in (implement `LogDestination`)
- No remote logging built-in (implement `LogDestination`)
- Single-threaded write per destination (by design)

## Related Packages

- `ARCDesignSystem` - Uses ARCLogger for internal logging
- `ARCNetworking` - Uses ARCLogger for network request logging
- `ARCStorage` - Uses ARCLogger for persistence operations

## Development Commands

```bash
make lint      # Run SwiftLint
make fix       # Apply SwiftFormat
make test      # Run tests
make clean     # Clean build
```
