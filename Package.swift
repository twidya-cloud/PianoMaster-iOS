// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PianoMaster",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PianoMaster",
            targets: ["PianoMaster"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PianoMaster",
            dependencies: [],
            path: "PianoMaster"
        ),
    ]
)
