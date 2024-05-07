// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "InfomaniakOnboarding",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "InfomaniakOnboarding",
            targets: ["InfomaniakOnboarding"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.4.3")
    ],
    targets: [
        .target(
            name: "InfomaniakOnboarding",
            dependencies: [.product(name: "Lottie", package: "lottie-spm")]
        ),
        .testTarget(
            name: "InfomaniakOnboardingTests",
            dependencies: ["InfomaniakOnboarding"]
        ),
    ]
)
