// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "TodoBoard",
    defaultLocalization: "zh-Hans",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "TodoBoard", targets: ["TodoBoard"]),
    ],
    targets: [
        .executableTarget(
            name: "TodoBoard",
            path: "Sources/TodoBoard",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "TodoBoardTests",
            dependencies: ["TodoBoard"],
            path: "Tests/TodoBoardTests"
        ),
    ]
)
