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

    func test_map_createsViewModel() {
        let articles = [uniqueArticle]
        let viewModel = ArticlesPresenter.map(articles, pageNumber: 1)

        XCTAssertEqual(viewModel.articles, articles)

    }
}
