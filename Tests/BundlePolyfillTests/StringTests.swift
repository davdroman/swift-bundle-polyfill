import Foundation
import Testing

@Suite struct StringTests {
	@Test func localized() {
		#expect(String(localized: "greeting") == "Hello")
	}

	@Test func interpolated() {
		let name = "Ana"
		#expect(String(localized: "hello \(name)") == "Hi Ana")
	}

	@Test func table() {
		#expect(String(localized: "farewell", table: "Farewells") == "Bye")
	}

	@Test func `default value`() {
		#expect(String(localized: "greeting", defaultValue: "Hi") == "Hello")
	}

	@Test @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
	func options() {
		#expect(String(localized: "greeting", options: .init()) == "Hello")
		#expect(String(localized: "greeting", defaultValue: "Hi", options: .init()) == "Hello")
	}

	@Test func `explicit bundle`() {
		#expect(String(localized: "greeting", bundle: .module) == "Hello")
	}

	@Test func `nil bundle uses main bundle`() {
		#expect(String(localized: "greeting", bundle: nil) == "greeting")
	}

	@Test func `nonisolated caller`() {
		#expect(nonisolatedGreeting() == "Hello")
	}

	@Test func `ns localized string`() {
		#expect(NSLocalizedString("greeting", comment: "") != "greeting")
		#expect(NSLocalizedString("farewell", tableName: "Farewells", comment: "") != "farewell")
		#expect(NSLocalizedString("greeting", bundle: .main, comment: "") == "greeting")
	}
}

/// The target isolates declarations to the main actor by default, so this checks the polyfill can be called from
/// nonisolated code.
private nonisolated func nonisolatedGreeting() -> String {
	String(localized: "greeting")
}
