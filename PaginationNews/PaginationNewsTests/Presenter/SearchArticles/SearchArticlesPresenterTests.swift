//
//  SearchArticlesPresenterTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/01/03.
//

import XCTest
import PaginationNews

class SearchArticlesPresenterTests: XCTestCase {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "SearchArticles"
		let bundle = Bundle(for: SearchArticlesPresenter.self)

		assertLocalizedKeyAndValuesExist(in: bundle, table)
	}
}
