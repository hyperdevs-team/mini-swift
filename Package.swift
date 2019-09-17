// swift-tools-version:5.0
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
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MiniSwift",
            dependencies: ["RxSwift", "NIOConcurrencyHelpers"]),
        .testTarget(
            name: "MiniSwiftTests",
            dependencies: ["MiniSwift","NIOConcurrencyHelpers", "RxSwift", "Nimble"]),
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
