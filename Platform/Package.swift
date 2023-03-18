// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Platform",
    defaultLocalization: "ko",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]),
        .library(
            name: "MenualUtil",
            targets: ["MenualUtil"]),
        .library(
            name: "MenualEntity",
            targets: ["MenualEntity"]),
        .library(
            name: "MenualRepository",
            targets: ["MenualRepository"]),
        .library(
            name: "MenualRepositoryTestSupport",
            targets: ["MenualRepositoryTestSupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/uber/RIBs", branch: "main"),
        .package(url: "https://github.com/devxoul/Then", exact: Version("3.0.0")),
        .package(url: "https://github.com/realm/realm-swift", exact: Version("10.34.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit", exact: Version("5.6.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift", exact: Version("6.0.0")),
        .package(url: "https://github.com/JJIKKYU/TOCropViewController", branch: "main"),
        .package(url: "https://github.com/JJIKKYU/FlexLayoutForSPM", branch: "master"),
        .package(url: "https://github.com/layoutBox/PinLayout", exact: Version("1.10.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DesignSystem",
            dependencies: [
                "MenualUtil",
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "CropViewController", package: "TOCropViewController"),
                .product(name: "FlexLayout", package: "FlexLayoutForSPM"),
                .product(name: "PinLayout", package: "PinLayout"),
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "MenualUtil",
            dependencies: [
                "MenualEntity",
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "Then", package: "Then"),
            ]
        ),
        .target(
            name: "MenualEntity",
            dependencies: [
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),
        .target(
            name: "MenualRepository",
            dependencies: [
                "MenualEntity",
                "MenualUtil",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),
        .target(
            name: "MenualRepositoryTestSupport",
            dependencies: [
                "MenualEntity",
                "MenualUtil",
                "MenualRepository",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),
        .testTarget(
            name: "MenualRepositoryTests",
            dependencies: [
                "MenualEntity",
                "MenualUtil",
                "MenualRepository",
                "MenualRepositoryTestSupport",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        )
    ]
)
