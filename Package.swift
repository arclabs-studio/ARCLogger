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
