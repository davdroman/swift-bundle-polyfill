import Foundation
import SwiftUI
import Testing

@Suite struct AttributedStringTests {
	@Test func localized() {
		#expect(text(AttributedString(localized: "greeting")) == "Hello")
		#expect(text(AttributedString(localized: "greeting", defaultValue: "Hi")) == "Hello")
	}

	@Test func table() {
		#expect(text(AttributedString(localized: "farewell", table: "Farewells")) == "Bye")
	}

	@Test func `including scope`() {
		#expect(text(AttributedString(localized: "greeting", including: \.swiftUI)) == "Hello")
		#expect(
			text(AttributedString(localized: "greeting", defaultValue: "Hi", including: \.swiftUI))
				== "Hello",
		)
		#expect(
			text(AttributedString(localized: "greeting", including: AttributeScopes.SwiftUIAttributes.self))
				== "Hello",
		)
		#expect(
			text(
				AttributedString(
					localized: "greeting",
					defaultValue: "Hi",
					including: AttributeScopes.SwiftUIAttributes.self,
				),
			) == "Hello",
		)
	}

	@Test @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
	func `localization options`() {
		let options = AttributedString.LocalizationOptions()
		#expect(text(AttributedString(localized: "greeting", options: options)) == "Hello")
		#expect(text(AttributedString(localized: "greeting", defaultValue: "Hi", options: options)) == "Hello")
		#expect(
			text(AttributedString(localized: "greeting", options: options, including: \.swiftUI)) == "Hello",
		)
		#expect(
			text(
				AttributedString(
					localized: "greeting",
					defaultValue: "Hi",
					options: options,
					including: \.swiftUI,
				),
			) == "Hello",
		)
		#expect(
			text(
				AttributedString(
					localized: "greeting",
					options: options,
					including: AttributeScopes.SwiftUIAttributes.self,
				),
			) == "Hello",
		)
		#expect(
			text(
				AttributedString(
					localized: "greeting",
					defaultValue: "Hi",
					options: options,
					including: AttributeScopes.SwiftUIAttributes.self,
				),
			) == "Hello",
		)
	}

	@Test func `nil bundle uses main bundle`() {
		#expect(text(AttributedString(localized: "greeting", bundle: nil)) == "greeting")
	}
}

private func text(_ string: AttributedString) -> String {
	String(string.characters)
}
