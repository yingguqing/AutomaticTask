// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AutomaticTask",
    platforms: [
        .macOS(.v12),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "AutomaticTask",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources:[
                .copy("config.json"),
                .copy("Module/BingWallpaper/bing-wallpaper.json"),
                .copy("Module/BingWallpaper/README.md")
            ]),
        .testTarget(
            name: "AutomaticTaskTests",
            dependencies: ["AutomaticTask"]),
    ]
)
