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
    ],
    targets: [
        .target(
            name: "SwiftNodeEditor",
            dependencies: ["Everything"]
        ),
        .target(
            name: "SwiftNodeEditorDemo",
            dependencies: ["SwiftNodeEditor"]
        ),
        .testTarget(
            name: "SwiftNodeEditorTests",
            dependencies: ["SwiftNodeEditor"]
        ),
    ]
)
