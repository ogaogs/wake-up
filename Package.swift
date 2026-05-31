// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WakeupCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "WakeupCore", targets: ["WakeupCore"]),
        .library(name: "WakeupApp", targets: ["WakeupApp"]),
    ],
    targets: [
        .target(name: "WakeupCore"),
        .testTarget(
            name: "WakeupCoreTests",
            dependencies: ["WakeupCore"]
        ),
        // Optional CLT smoke runner: verifies the pure core at runtime
        // without Xcode. Now redundant with `swift test`; safe to delete.
        .executableTarget(
            name: "WakeupCoreSmoke",
            dependencies: ["WakeupCore"]
        ),
        // SwiftUI presentation layer consumed by the Xcode iOS app target
        // (App/Wakeup.xcodeproj) and build-verifiable here via `swift build`
        // since SwiftUI is cross-platform.
        .target(
            name: "WakeupApp",
            dependencies: ["WakeupCore"]
        ),
    ]
)
