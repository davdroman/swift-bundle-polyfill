import Foundation
import PackagePlugin

@main
struct BundlePolyfill: BuildToolPlugin {
	func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
		guard target is SwiftSourceModuleTarget else { return [] }
		return try createBuildCommands(workDirectory: context.pluginWorkDirectoryURL, targetName: target.name)
	}
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension BundlePolyfill: XcodeBuildToolPlugin {
	func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
		try createBuildCommands(workDirectory: context.pluginWorkDirectoryURL, targetName: target.displayName)
	}
}
#endif

extension BundlePolyfill {
	/// Writes the polyfill source into the target's plugin work directory and copies it into the target's sources.
	///
	/// A build tool plugin can only add sources as the outputs of a command, so the plugin writes the source itself
	/// and copies it with `cp`. It rewrites the source only when it changes, so unchanged builds skip the copy.
	private func createBuildCommands(workDirectory: URL, targetName: String) throws -> [Command] {
		let source = workDirectory.appending(component: "BundlePolyfill.swift.in")
		let output = workDirectory.appending(component: "BundlePolyfill.swift")

		if (try? String(contentsOf: source, encoding: .utf8)) != polyfillSource {
			try FileManager.default.createDirectory(at: workDirectory, withIntermediateDirectories: true)
			try polyfillSource.write(to: source, atomically: true, encoding: .utf8)
		}

		return [
			.buildCommand(
				displayName: "Generating BundlePolyfill for \(targetName)",
				executable: URL(filePath: "/bin/cp"),
				arguments: [source.path(percentEncoded: false), output.path(percentEncoded: false)],
				inputFiles: [source],
				outputFiles: [output],
			),
		]
	}
}
