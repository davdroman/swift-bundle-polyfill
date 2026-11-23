# BundlePolyfill

[![CI](https://github.com/davdroman/swift-bundle-polyfill/actions/workflows/ci.yml/badge.svg)](https://github.com/davdroman/swift-bundle-polyfill/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdavdroman%2Fswift-bundle-polyfill%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/davdroman/swift-bundle-polyfill)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdavdroman%2Fswift-bundle-polyfill%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/davdroman/swift-bundle-polyfill)

Make Apple's localization and asset APIs default to `#bundle`, until Apple does.

## The Problem

Apple's localization and asset APIs look up resources in the main bundle unless you pass `bundle:`. In a Swift package or framework, these calls quietly miss the module's own strings and assets:

```swift
Text("Welcome")                     // always shows "Welcome", untranslated
String(localized: "\(count) items") // always returns the English text
Image("logo")                       // renders nothing
```

Forgetting `bundle: .module` doesn't fail to compile. It only shows up at runtime, and for strings only when the app runs in another language.

Foundation's `#bundle` macro, introduced with Xcode 26 at WWDC25, resolves to the bundle of the code that uses it: `Bundle.module` in a package target, `Bundle.main` in an app. It back-deploys to iOS 15, macOS 12, tvOS 15, watchOS 8, and visionOS 1. But Apple's APIs still default to the main bundle, so [Code-along: Explore localization with Xcode](https://developer.apple.com/videos/play/wwdc2025/225/?time=598) has framework and package authors pass `bundle: #bundle` to every call.

## The Solution

BundlePolyfill is a build tool plugin that adds overloads of those APIs to each target it's applied to, with `bundle` defaulting to `#bundle`. Because the overloads are declared in the target itself, they apply in every file without an import, so no file can miss them.

This package exists to be made obsolete. Once Apple's APIs default to `#bundle`, remove the plugin and your code keeps working unchanged.

## Requirements

Swift 6.2 (Xcode 26) or later, targeting iOS 15, Mac Catalyst 15, macOS 12, tvOS 15, visionOS 1, or watchOS 8 or later.

## Installation

Add the package to your dependencies:

```swift
.package(url: "https://github.com/davdroman/swift-bundle-polyfill", from: "0.1.0"),
```

Then apply the plugin to each target that has localized strings or assets:

```swift
.target(
	name: "Onboarding",
	resources: [
		.process("Localizable.xcstrings"),
		.process("Assets.xcassets"),
	],
	plugins: [
		.plugin(name: "BundlePolyfill", package: "swift-bundle-polyfill"),
	],
),
```

For a target in an Xcode project, add `BundlePolyfill` under the target's **Build Phases › Run Build Tool Plug-ins**.

## Usage

Write the same code you would in an app target:

```swift
Text("Welcome")
Image("logo")
String(localized: "\(count) items remaining")
```

Each call resolves in the bundle of the target it's written in. Xcode still extracts these strings into the target's String Catalog, including their `table`, `defaultValue`, and `comment` arguments.

Passing `bundle:` still works as before. To look up a resource in the main bundle from a package target, pass `bundle: nil` or `bundle: .main`.

### Covered APIs

| API | Since |
| --- | --- |
| `String(localized:…)`, including `defaultValue:` and `options:` | iOS 15, macOS 12, tvOS 15, watchOS 8 |
| `AttributedString(localized:…)`, including `defaultValue:`, `options:`, and `including:` | iOS 15, macOS 12, tvOS 15, watchOS 8 |
| `NSLocalizedString(_:tableName:bundle:value:comment:)` | iOS 15, macOS 12, tvOS 15, watchOS 8 |
| `Text(_:tableName:bundle:comment:)` | iOS 15, macOS 12, tvOS 15, watchOS 8 |
| `Image(_:bundle:)`, `Image(_:bundle:label:)`, `Image(decorative:bundle:)` | iOS 15, macOS 12, tvOS 15, watchOS 8 |
| `Image(_:variableValue:bundle:)` and its `label:` and `decorative:` variants | iOS 16, macOS 13, tvOS 16, watchOS 9 |
| `Color(_:bundle:)` | iOS 15, macOS 12, tvOS 15, watchOS 8 |

## Limitations

- Apply the plugin only to targets with resources. In a package target without resources, `#bundle` has no bundle to resolve to, so calls that rely on the default fail to compile with "No resource bundle is available for this module".
- APIs without a `bundle:` parameter always use the main bundle, and the plugin can't change that. These include SwiftUI initializers such as `Button("Save")`, `Label`, and `navigationTitle(_:)`, string literals used as `LocalizedStringResource`, and UIKit and AppKit APIs such as `UIImage(named:)`. In a package target, pass them a `Text` or a `String(localized:)` value instead.
