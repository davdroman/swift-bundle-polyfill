// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "swift-bundle-polyfill",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v15),
		.macCatalyst(.v15),
		.macOS(.v12),
		.tvOS(.v15),
		.visionOS(.v1),
		.watchOS(.v8),
	],
	products: [
		.plugin(name: "BundlePolyfill", targets: ["BundlePolyfill"]),
	],
	targets: [
		.plugin(name: "BundlePolyfill", capability: .buildTool()),
		.testTarget(
			name: "BundlePolyfillTests",
			resources: [
				.process("Resources"),
			],
			swiftSettings: [
				.defaultIsolation(MainActor.self),
			],
			plugins: [
				"BundlePolyfill",
			],
		),
	],
)

for target in package.targets where target.type != .plugin {
	target.swiftSettings = target.swiftSettings ?? []
	target.swiftSettings? += [
		.enableUpcomingFeature("ExistentialAny"),
		.enableUpcomingFeature("ImmutableWeakCaptures"),
		.enableUpcomingFeature("InferIsolatedConformances"),
		.enableUpcomingFeature("InternalImportsByDefault"),
		.enableUpcomingFeature("MemberImportVisibility"),
		.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
	]
}
