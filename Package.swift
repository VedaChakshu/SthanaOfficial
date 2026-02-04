// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sthana",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Sthana",
            targets: ["Sthana"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Sthana",
            resources: [
                .copy("Resources/cities500.sqlite")
            ]
        ),
        .testTarget(
            name: "SthanaTests",
            dependencies: ["Sthana"]
        ),
    ]
)
