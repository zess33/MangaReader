// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MangaReader",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MangaReaderCore",
            targets: ["MangaReaderCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MangaReaderCore",
            path: "MangaReader",
            exclude: ["Resources", "App/MangaReaderApp.swift"]
        ),
        .testTarget(
            name: "MangaReaderTests",
            dependencies: ["MangaReaderCore"],
            path: "Tests/MangaReaderTests"
        )
    ]
)
