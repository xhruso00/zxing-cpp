// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ZXingCppWrapper",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ZXingCppWrapper",
            type: .static,
            targets: ["ZXingCppWrapper"])
    ],
    targets: [
        .binaryTarget(
            name: "ZXingCpp",
            path: "ZXingCpp.xcframework"
        ),
        .target(
            name: "ZXingCppWrapper",
            dependencies: ["ZXingCpp"],
            path: "Sources/Wrapper",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath(".")
            ]
        )
    ],
    cxxLanguageStandard: .gnucxx17
)
