// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SystemSound",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "SystemSound",
            targets: ["SystemSound"]
        ),
    ],
    targets: [
        .target(
            name: "SystemSound"
        ),
        .testTarget(
            name: "SystemSoundTests",
            dependencies: ["SystemSound"]
        ),
    ]
)
