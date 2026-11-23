import Foundation
import SwiftUI
import Testing

@Suite struct SwiftUITests {
	@Test func text() {
		#expect(Text("greeting") == Text("greeting", tableName: nil, bundle: Optional(.module), comment: nil))
		#expect(Text("greeting") != Text("greeting", bundle: nil))
		#expect(
			Text("farewell", tableName: "Farewells")
				== Text("farewell", tableName: "Farewells", bundle: Optional(.module), comment: nil),
		)
	}

	@Test func `text from string`() {
		let key = "greeting"
		#expect(Text(key) == Text(verbatim: "greeting"))
	}

	@Test func image() {
		#expect(Image("dot") == Image("dot", bundle: Optional(.module)))
		#expect(Image("dot") != Image("dot", bundle: nil))
		#expect(Image("dot", label: Text("Dot")) == Image("dot", bundle: Optional(.module), label: Text("Dot")))
		#expect(Image(decorative: "dot") == Image(decorative: "dot", bundle: Optional(.module)))
	}

	@Test @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
	func `image variable value`() {
		#expect(Image("dot", variableValue: 0.5) == Image("dot", variableValue: 0.5, bundle: Optional(.module)))
		#expect(
			Image("dot", variableValue: 0.5, label: Text("Dot"))
				== Image("dot", variableValue: 0.5, bundle: Optional(.module), label: Text("Dot")),
		)
		#expect(
			Image(decorative: "dot", variableValue: 0.5)
				== Image(decorative: "dot", variableValue: 0.5, bundle: Optional(.module)),
		)
	}

	@Test func color() {
		#expect(Color("brand") == Color("brand", bundle: Optional(.module)))
		#expect(Color("brand") != Color("brand", bundle: nil))
	}
}
