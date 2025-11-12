// swift-tools-version: 6.0

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
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.4.3"),
        .package(url: "https://github.com/LottieFiles/dotlottie-ios", from: "0.11.1")
    ],
    targets: [
        .target(
            name: "InfomaniakOnboarding",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "DotLottie", package: "dotlottie-ios")
            ]
        ),
        .testTarget(
            name: "InfomaniakOnboardingTests",
            dependencies: ["InfomaniakOnboarding"]
        ),
    ]
)
