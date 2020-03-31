// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSegmentRecordingView",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "SSegmentRecordingView",
            targets: ["SSegmentRecordingView"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "SSegmentRecordingView",
            dependencies: [],
            path: "SSegmentRecordingView")
    ]
)
