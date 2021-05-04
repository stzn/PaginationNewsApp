//
//  ArticlesPresenterTests.swift
//  PaginationNewsTests
//

//

import XCTest
import PaginationNews

class ArticlesPresenterTests: XCTestCase {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "Articles"
		let bundle = Bundle(for: ArticlesPresenter.self)

		assertLocalizedKeyAndValuesExist(in: bundle, table)
	}
}
