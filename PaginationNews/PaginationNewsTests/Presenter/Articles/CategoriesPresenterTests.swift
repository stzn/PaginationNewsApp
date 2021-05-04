//
//  ArticlesPresenterTests.swift
//  PaginationNewsTests
//

//

import XCTest
import PaginationNews

class CategoriesPresenterTests: XCTestCase {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "Categories"
		let bundle = Bundle(for: CategoriesPresenter.self)

		assertLocalizedKeyAndValuesExist(in: bundle, table)
	}
}
