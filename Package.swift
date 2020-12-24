// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SwiftyMediaGallery",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name:"SwiftyMediaGallery",targets:["SwiftyMediaGallery"]),
    ],
    dependencies: [
        .package(url:"https://github.com/combineopensource/CombineDataSources", from:"0.2.5"),
    ],
    targets: [
        .target(name: "SwiftyMediaGallery", dependencies: ["CombineDataSources"]),
    ]
)
