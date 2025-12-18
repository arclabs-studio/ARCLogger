// main.swift
// ARCLoggerDemo
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import ARCLogger
import Foundation

// MARK: - Demo Runner

print("""
╔══════════════════════════════════════════════════════════════════╗
║                      ARCLogger Demo                              ║
║               Privacy-Conscious Structured Logging               ║
╚══════════════════════════════════════════════════════════════════╝
""")

// MARK: - 1. Basic Usage

printSection("1. Basic Usage")

let logger = ARCLogger()

logger.debug("Application starting...")
logger.info("User interface loaded")
logger.warning("Cache is getting full")
logger.error("Failed to load resource")
logger.critical("Database connection lost")

// MARK: - 2. Logging with Metadata

printSection("2. Logging with Metadata")

logger.info("User logged in", metadata: [
    "userId": .public("USR-12345"),
    "sessionId": .public("abc-def-ghi")
])

logger.info("API request completed", metadata: [
    "endpoint": .public("/api/users"),
    "method": .public("GET"),
    "statusCode": .public("200"),
    "duration": .public("142ms")
])

// MARK: - 3. Privacy Levels (Development Mode)

printSection("3. Privacy Levels - Development Mode")

let devLogger = ARCLogger(isProduction: false)

print("In development, all data is visible:\n")

devLogger.info("Processing user data", metadata: [
    "userId": .public("USR-12345"), // Always visible
    "email": .private("john@example.com"), // Visible in dev, hidden in prod
    "apiKey": .sensitive("sk_live_abc123") // Always hidden
])

// MARK: - 4. Privacy Levels (Production Mode)

printSection("4. Privacy Levels - Production Mode")

let prodLogger = ARCLogger(isProduction: true)

print("In production, sensitive data is redacted:\n")

prodLogger.info("Processing user data", metadata: [
    "userId": .public("USR-12345"), // Always visible
    "email": .private("john@example.com"), // [REDACTED]
    "apiKey": .sensitive("sk_live_abc123") // [REDACTED]
])

// MARK: - 5. Custom Destination Configuration

printSection("5. Custom Console Configuration")

let verboseConsole = ConsoleDestination(
    minimumLevel: .debug,
    includeTimestamp: true,
    includeSourceLocation: true,
    useEmoji: true
)

let verboseLogger = ARCLogger(destinations: [verboseConsole])

print("With source location enabled:\n")
verboseLogger.info("This log includes file and line info")

// MARK: - 6. Filtering by Log Level

printSection("6. Filtering by Log Level")

let warningOnlyConsole = ConsoleDestination(minimumLevel: .warning)
let filteredLogger = ARCLogger(destinations: [warningOnlyConsole])

print("Only .warning and above will appear:\n")
filteredLogger.debug("This won't appear (debug < warning)")
filteredLogger.info("This won't appear (info < warning)")
filteredLogger.warning("This WILL appear")
filteredLogger.error("This WILL appear")

// MARK: - 7. Multiple Destinations

printSection("7. Multiple Destinations")

let consoleDebug = ConsoleDestination(minimumLevel: .debug, useEmoji: true)
let consoleErrors = ConsoleDestination(minimumLevel: .error, useEmoji: false)

let multiLogger = ARCLogger(destinations: [consoleDebug, consoleErrors])

print("Errors appear twice (in both destinations):\n")
multiLogger.info("Info message - appears once")
multiLogger.error("Error message - appears in both destinations")

// MARK: - 8. Shared Instance

printSection("8. Shared Instance")

print("Using the shared singleton:\n")
ARCLogger.shared.info("Message from shared instance")

// MARK: - 9. Practical Example: User Authentication Flow

printSection("9. Practical Example: Authentication Flow")

simulateAuthFlow()

// MARK: - End

print("""

╔══════════════════════════════════════════════════════════════════╗
║                      Demo Complete                               ║
║                                                                  ║
║  Run with: swift run ARCLoggerDemo                               ║
╚══════════════════════════════════════════════════════════════════╝
""")

// MARK: - Helper Functions

func printSection(_ title: String) {
    print("\n" + String(repeating: "─", count: 60))
    print(" \(title)")
    print(String(repeating: "─", count: 60) + "\n")
}

func simulateAuthFlow() {
    let authLogger = ARCLogger(
        subsystem: "com.example.app",
        category: "Auth",
        isProduction: false
    )

    // Step 1: Login attempt
    authLogger.info("Login attempt started", metadata: [
        "username": .private("john_doe"),
        "method": .public("password")
    ])

    // Step 2: Validation
    authLogger.debug("Validating credentials...")

    // Step 3: Token generation
    authLogger.info("Authentication successful", metadata: [
        "userId": .public("USR-12345"),
        "token": .sensitive("eyJhbGciOiJIUzI1NiIs..."),
        "expiresIn": .public("3600s")
    ])

    // Step 4: Session created
    authLogger.info("Session created", metadata: [
        "sessionId": .public("sess_abc123"),
        "ip": .private("192.168.1.100"),
        "userAgent": .private("Mozilla/5.0...")
    ])
}
