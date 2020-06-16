// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name = "Communicator"

let package = Package(
    name: name,
	platforms: [.iOS(.v10), .watchOS(.v3)],
    products: [.library(name: name, targets: [name])],
	targets: [.target(name: name, path: "Sources")],
	swiftLanguageVersions: [.v5]
)
