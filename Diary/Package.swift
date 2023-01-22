// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Diary",
    defaultLocalization: "ko",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        .library(
            name: "DiaryDetailImage",
            targets: ["DiaryDetailImage"]),
        .library(
            name: "DiaryBottomSheet",
            targets: ["DiaryBottomSheet"]),
        .library(
            name: "DiaryDetail",
            targets: ["DiaryDetail"]),
        .library(
            name: "DiarySearch",
            targets: ["DiarySearch"]),
        .library(
            name: "DiaryHome",
            targets: ["DiaryHome"]),
        .library(
            name: "DiaryTempSave",
            targets: ["DiaryTempSave"]),
        .library(
            name: "DiaryWriting",
            targets: ["DiaryWriting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/devxoul/Then", exact: Version("3.0.0")),
        .package(url: "https://github.com/realm/realm-swift", exact: Version("10.34.0")),
        .package(url: "https://github.com/SnapKit/SnapKit", exact: Version("5.6.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift", exact: Version("6.0.0")),
        .package(path: "../Platform"),
        .package(path: "../Profile"),
        .package(url: "https://github.com/ZipArchive/ZipArchive", exact: Version("2.4.3")),
    ],
    targets: [
        .target(
            name: "DiaryDetailImage",
            dependencies: [
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "Then", package: "Then"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
            ]
        ),
        .target(
            name: "DiaryBottomSheet",
            dependencies: [
                "DiaryWriting",
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
            ]
        ),
        .target(
            name: "DiaryDetail",
            dependencies: [
                "DiaryBottomSheet",
                "DiaryDetailImage",
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
            ]
        ),
        .target(
            name: "DiarySearch",
            dependencies: [
                "DiaryDetail",
                .product(name: "DesignSystem", package: "Platform"),
                .product(name: "MenualEntity", package: "Platform"),
            ]
        ),
        .target(
            name: "DiaryHome",
            dependencies: [
                "DiarySearch",
                "DiaryWriting",
                "DiaryDetail",
                "DiaryBottomSheet",
                .product(name: "ProfileDesignSystem", package: "Profile"),
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "MenualRepository", package: "Platform"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "Then", package: "Then"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "ZipArchive", package: "ZipArchive")
            ]
        ),
        .target(
            name: "DiaryTempSave",
            dependencies: [
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "DesignSystem", package: "Platform"),
            ]
        ),
        .target(
            name: "DiaryWriting",
            dependencies: [
                "DiaryTempSave",
                .product(name: "MenualEntity", package: "Platform"),
                .product(name: "DesignSystem", package: "Platform"),
            ]
        ),
    ]
)
