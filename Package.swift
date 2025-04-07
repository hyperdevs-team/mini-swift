// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Mini",
    platforms: [
        .iOS("14.1"),
        .macOS(.v11),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "Mini",
            targets: ["Mini"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Mini",
            dependencies: [],
            path: "Sources",
            exclude: [
                "../bin",
                "../_config.yml",
                "../Dangerfile",
                "../Gemfile",
                "../Gemfile.lock",
                "../Mintfile",
                "../Rakefile",
            ]
        ),
        .testTarget(
            name: "MiniSwiftTests",
            dependencies: ["Mini"],
            path: "Tests"
        ),
    ]
)
