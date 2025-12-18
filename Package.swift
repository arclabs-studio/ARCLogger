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
        ),
        .executable(
            name: "ARCLoggerDemo",
            targets: ["ARCLoggerDemo"]
        )
    ],
    targets: [
        .target(
            name: "ARCLogger"
        ),
        .executableTarget(
            name: "ARCLoggerDemo",
            dependencies: ["ARCLogger"]
        ),
        .testTarget(
            name: "ARCLoggerTests",
            dependencies: ["ARCLogger"]
        )
    ]
)
