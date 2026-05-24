// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Police",
    products: [
        .executable(name: "police", targets: ["Police"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "602.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Police",
            dependencies: [
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ]
        )
    ]
)
