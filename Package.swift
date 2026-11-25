// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyLittleSpiderMan",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "MyLittleSpiderMan",
            path: "src",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("QuartzCore")
            ]
        )
    ]
)
