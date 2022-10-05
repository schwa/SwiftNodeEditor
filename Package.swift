// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNodeEditor",
    platforms: [
        .iOS("15.0"),
        .macOS("12.0"),
        .macCatalyst("15.0"),
    ],
    products: [
        .library(
            name: "SwiftNodeEditor",
            targets: ["SwiftNodeEditor"]
        ),
        .library(
            name: "SwiftNodeEditorDemo",
            targets: ["SwiftNodeEditorDemo"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/schwa/Everything", branch: "main"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.3")),
    ],
    targets: [
        .target(
            name: "SwiftNodeEditor",
            dependencies: [
                "Everything",
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .target(
            name: "SwiftNodeEditorDemo",
            dependencies: [
                "SwiftNodeEditor",
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .testTarget(
            name: "SwiftNodeEditorTests",
            dependencies: ["SwiftNodeEditor"]
        ),
    ]
)
