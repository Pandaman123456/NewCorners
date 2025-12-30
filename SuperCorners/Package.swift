// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SuperCorners",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SuperCorners", targets: ["SuperCorners"])
    ],
    targets: [
        .executableTarget(
            name: "SuperCorners",
            path: "Sources/SuperCorners",
            resources: [
                .process("Resources") // Placeholder if we had assets, creating the folder just in case
            ]
        )
    ]
)
