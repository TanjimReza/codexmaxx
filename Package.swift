// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CodexMaxx",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.9.1"),
    ],
    targets: [
        .executableTarget(
            name: "CodexMaxx",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle"),
            ],
            path: "Sources/CodexMaxx",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
    ])
