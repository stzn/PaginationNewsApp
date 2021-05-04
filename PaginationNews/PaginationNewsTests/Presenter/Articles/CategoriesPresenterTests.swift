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

	func test_localizedStrings_haveAllCategories() {
		TopHeadlineCategory.allCases.forEach { category in
			XCTAssertNotEqual(CategoriesPresenter.displayedCategoryName(category), "not found", "\(category.rawValue)")
		}
	}
}
