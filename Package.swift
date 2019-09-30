// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mini",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Mini",
            targets: ["MiniSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", .exact("2.7.1")),
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2")),
        // Development
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.35.8"), // dev
        .package(url: "https://github.com/shibapm/Rocket", from: "0.4.0"), // dev
        .package(url: "https://github.com/Realm/SwiftLint", from: "0.28.1"), // dev
        .package(url: "https://github.com/eneko/SourceDocs", from: "0.5.1"), // dev
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MiniSwift",
            dependencies: ["RxSwift", "NIOConcurrencyHelpers"]),
        .testTarget(
            name: "MiniSwiftTests",
            dependencies: ["MiniSwift", "NIOConcurrencyHelpers", "RxSwift", "Nimble", "RxTest", "RxBlocking"]) // dev
    ],
    swiftLanguageVersions: [.version("4"), .version("4.2"), .version("5")]
)

#if canImport(PackageConfig)
    import PackageConfig

    let config = PackageConfiguration([
        "rocket": [
            "before": [
                "rake docs",
                "Scripts/update_changelog.sh",
            ],
        ],
    ]).write()
#endif
