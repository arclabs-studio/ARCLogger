// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCLogger",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "ARCLogger",
            targets: ["ARCLogger"]
        )
    ],
    targets: [
        .target(
            name: "ARCLogger",
            path: "Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ARCLoggerTests",
            dependencies: ["ARCLogger"],
            path: "Tests"
        )
    ]
)
