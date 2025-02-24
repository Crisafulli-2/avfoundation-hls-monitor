// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "avfoundation-hls-monitor",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "hlsmonitor",
            targets: ["HLSMonitor"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0")
    ],
    targets: [
        .executableTarget(
            name: "HLSMonitor",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Rainbow"
            ]
        )
    ]
)