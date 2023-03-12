// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Profile",
    defaultLocalization: "ko",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ProfileOpensource",
            targets: ["ProfileOpensource"]),
        .library(
            name: "ProfilePassword",
            targets: ["ProfilePassword"]),
        .library(
            name: "ProfileHome",
            targets: ["ProfileHome"]),
        .library(
            name: "ProfileDeveloper",
            targets: ["ProfileDeveloper"]),
        .library(
            name: "ProfileDesignSystem",
            targets: ["ProfileDesignSystem"]),
        .library(
            name: "ProfileRestore",
            targets: ["ProfileRestore"]),
        .library(
            name: "ProfileRestoreConfirm",
            targets: ["ProfileRestoreConfirm"]),
        .library(
            name: "ProfileBackup",
            targets: ["ProfileBackup"]),
    ],
    dependencies: [
        .package(url: "https://github.com/uber/RIBs", branch: "main"),
        .package(url: "https://github.com/realm/realm-swift", exact: Version("10.34.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift", exact: Version("6.0.0")),
        .package(path: "../Platform"),
        .package(url: "https://github.com/ZipArchive/ZipArchive", exact: Version("2.4.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ProfileOpensource",
            dependencies: [
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "DesignSystem", package: "Platform")
            ]
        ),
        .target(
            name: "ProfilePassword",
            dependencies: [
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "MenualRepository", package: "Platform"),
            ]
        ),
        .target(
            name: "ProfileHome",
            dependencies: [
                "ProfileOpensource",
                "ProfileDeveloper",
                "ProfilePassword",
                "ProfileBackup",
                "ProfileRestore",
                "ProfileDesignSystem",
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "MenualRepository", package: "Platform")
            ]
        ),
        .target(
            name: "ProfileDeveloper",
            dependencies: [
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "MenualRepository", package: "Platform"),
            ]
        ),
        .target(
            name: "ProfileDesignSystem",
            dependencies: [
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
            ]
        ),
        .target(
            name: "ProfileBackup",
            dependencies: [
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "ZipArchive", package: "ZipArchive"),
                .product(name: "MenualRepository", package: "Platform")
            ]
        ),
        .target(
            name: "ProfileRestore",
            dependencies: [
                "ProfileRestoreConfirm",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "ZipArchive", package: "ZipArchive"),
                .product(name: "MenualUtil", package: "Platform"),
                .product(name: "MenualRepository", package: "Platform")
            ]
        ),
        .target(
            name: "ProfileRestoreConfirm",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "ZipArchive", package: "ZipArchive"),
                .product(name: "MenualUtil", package: "Platform"),
                .product(name: "MenualRepository", package: "Platform")
            ]
        ),
        .testTarget(
            name: "ProfileBackupTests",
            dependencies: [
                "ProfileBackup",
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "MenualRepository", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "MenualRepositoryTestSupport", package: "Platform"),
            ]
        ),
        .testTarget(
            name: "ProfileRestoreConfirmTests",
            dependencies: [
                "ProfileRestoreConfirm",
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "MenualRepository", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "MenualRepositoryTestSupport", package: "Platform"),
            ]
        )
    ]
)
