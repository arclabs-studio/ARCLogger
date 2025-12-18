// LogPrivacyTests.swift
// ARCLoggerTests
//
// Copyright (c) 2025 ARC Labs Studio
// Licensed under MIT License

import Testing
@testable import ARCLogger

@Suite("LogPrivacy Tests")
struct LogPrivacyTests {
    // MARK: - Privacy Level Tests

    @Test("Privacy levels are distinct")
    func privacyLevelsAreDistinct() {
        #expect(LogPrivacy.public != LogPrivacy.private)
        #expect(LogPrivacy.private != LogPrivacy.sensitive)
        #expect(LogPrivacy.public != LogPrivacy.sensitive)
    }

    @Test("Same privacy levels are equal")
    func sameLevelsAreEqual() {
        #expect(LogPrivacy.public == LogPrivacy.public)
        #expect(LogPrivacy.private == LogPrivacy.private)
        #expect(LogPrivacy.sensitive == LogPrivacy.sensitive)
    }
}

@Suite("LogValue Tests")
struct LogValueTests {
    // MARK: - Initialization Tests

    @Test("LogValue initializes with value and privacy")
    func initializesCorrectly() {
        let logValue = LogValue("test", privacy: .public)
        #expect(logValue.value == "test")
        #expect(logValue.privacy == .public)
    }

    // MARK: - Factory Method Tests

    @Test("Public factory creates public log value")
    func publicFactoryWorks() {
        let logValue = LogValue.public("visible")
        #expect(logValue.value == "visible")
        #expect(logValue.privacy == .public)
    }

    @Test("Private factory creates private log value")
    func privateFactoryWorks() {
        let logValue = LogValue.private("hidden")
        #expect(logValue.value == "hidden")
        #expect(logValue.privacy == .private)
    }

    @Test("Sensitive factory creates sensitive log value")
    func sensitiveFactoryWorks() {
        let logValue = LogValue.sensitive("secret")
        #expect(logValue.value == "secret")
        #expect(logValue.privacy == .sensitive)
    }

    // MARK: - Description Tests

    @Test("Description returns raw value")
    func descriptionReturnsValue() {
        let logValue = LogValue.public("test value")
        #expect(logValue.description == "test value")
    }

    // MARK: - Redaction Tests

    @Test("Public values are never redacted in development")
    func publicNotRedactedInDev() {
        let logValue = LogValue.public("visible")
        #expect(logValue.redacted(isProduction: false) == "visible")
    }

    @Test("Public values are never redacted in production")
    func publicNotRedactedInProd() {
        let logValue = LogValue.public("visible")
        #expect(logValue.redacted(isProduction: true) == "visible")
    }

    @Test("Private values are visible in development")
    func privateVisibleInDev() {
        let logValue = LogValue.private("hidden")
        #expect(logValue.redacted(isProduction: false) == "hidden")
    }

    @Test("Private values are redacted in production")
    func privateRedactedInProd() {
        let logValue = LogValue.private("hidden")
        #expect(logValue.redacted(isProduction: true) == "<private>")
    }

    @Test("Sensitive values are always redacted in development")
    func sensitiveRedactedInDev() {
        let logValue = LogValue.sensitive("secret")
        #expect(logValue.redacted(isProduction: false) == "<sensitive>")
    }

    @Test("Sensitive values are always redacted in production")
    func sensitiveRedactedInProd() {
        let logValue = LogValue.sensitive("secret")
        #expect(logValue.redacted(isProduction: true) == "<sensitive>")
    }

    // MARK: - Edge Cases

    @Test("Empty string values are handled correctly")
    func emptyStringHandled() {
        let logValue = LogValue.public("")
        #expect(logValue.value.isEmpty)
        #expect(logValue.redacted(isProduction: false).isEmpty)
    }

    @Test("Unicode values are handled correctly")
    func unicodeHandled() {
        let logValue = LogValue.public("Hello")
        #expect(logValue.value == "Hello")
        #expect(logValue.redacted(isProduction: false) == "Hello")
    }

    @Test("Special characters are preserved")
    func specialCharsPreserved() {
        let specialValue = "test@email.com <script>alert('xss')</script>"
        let logValue = LogValue.public(specialValue)
        #expect(logValue.redacted(isProduction: false) == specialValue)
    }
}
