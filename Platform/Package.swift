// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Platform",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]),
        .library(
            name: "MenualUtil",
            targets: ["MenualUtil"]),
    ],
    dependencies: [
        .package(url: "https://github.com/devxoul/Then", exact: Version("3.0.0")),
        .package(url: "https://github.com/realm/realm-swift", exact: Version("10.34.0")),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "9.0.0")
          ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DesignSystem",
            dependencies: [
                "MenualUtil",
            ]
        ),
        .target(
            name: "MenualUtil",
            dependencies: [
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            ]
        ),
    ]
)
