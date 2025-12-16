// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCLogger",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ARCLogger",
            targets: ["ARCLogger"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/arclabs-studio/ARCAgentsDocs.git", from: "1.0.0"),
        .package(url: "https://github.com/arclabs-studio/ARCDevTools.git", from: "1.1.4"),
    ],
    targets: [
        .target(
            name: "ARCLogger",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ARCLoggerTests",
            dependencies: ["ARCLogger"]
        )
    ]
)
