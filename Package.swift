// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swift-htslib",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "Htslib", targets: ["Htslib"]),
    ],
    targets: [
        .systemLibrary(
            name: "CHtslib",
            pkgConfig: "htslib",
            providers: [.brew(["htslib"]), .apt(["libhts-dev"])]
        ),
        .target(
            name: "CHTSlibShims",
            dependencies: ["CHtslib"],
            publicHeadersPath: "include"
        ),
        .target(
            name: "Htslib",
            dependencies: ["CHtslib", "CHTSlibShims"],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "HtslibTests",
            dependencies: ["Htslib"],
            resources: [.copy("TestData")]
        ),
    ]
)
