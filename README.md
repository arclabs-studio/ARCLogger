# ARCLogger

> Professional structured logging for ARC Labs Studio packages

## Features

- 🎯 **Multiple log levels**: debug, info, warning, error, critical
- 📦 **Pluggable destinations**: Console, OSLog, or custom
- 🔒 **Type-safe & Sendable**: Full Swift 6 concurrency support
- 🌐 **Specialized loggers**: Pre-built NetworkLogger for HTTP traffic
- 🧪 **Testable**: Mock destinations for unit testing
- 🚀 **Zero overhead in Release**: DEBUG-only console output

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCLogger.git", from: "1.0.0")
]
```

## Quick Start

```swift
import ARCLogger

let logger = ARCLogger(
    category: "MyFeature",
    subsystem: "com.arclabs.myapp"
)

logger.debug("Starting operation")
logger.info("User logged in", metadata: ["userId": "123"])
logger.warning("Low disk space")
logger.error("Failed to save", error: someError)
logger.critical("Database corrupted")
```

## Network Logging

```swift
import ARCLogger

let networkLogger = NetworkLogger()

// Log requests
networkLogger.logRequest(urlRequest)

// Log responses with pretty JSON
networkLogger.logResponse(httpResponse, data: responseData)

// Log errors
networkLogger.logError(error, context: "Fetching user profile")
```

## Custom Destinations

```swift
struct FileDestination: LogDestination {
    let minimumLevel: LogLevel = .warning

    func write(level: LogLevel, message: String, context: LogContext) {
        // Write to file
    }
}

let logger = ARCLogger(
    category: "App",
    subsystem: "com.arclabs.app",
    destinations: [
        ConsoleDestination(),
        FileDestination()
    ]
)
```

## License

MIT License - ARC Labs Studio © 2024
