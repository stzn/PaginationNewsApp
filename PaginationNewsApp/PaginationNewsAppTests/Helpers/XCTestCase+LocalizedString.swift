//
//  XCTestCase+LocalizedString.swift
//  PaginationNewsAppTests
//
//

import Foundation
import XCTest
import PaginationNews

extension XCTestCase {
	func sharedLocalized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
		let table = "Shared"
		let bundle = Bundle(for: Presenter<Never, AnyView>.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

	private class AnyView: ContentView {
		typealias Content = Never
		func display(_ model: Never) {}
	}
}
