// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "NewHomz",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.2"),
        .package(url: "https://github.com/LiveUI/S3", from: "3.0.0-RC3.2"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "SWXMLHash", "Redis", "S3"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

