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

    func test_map_createsViewModel() {
        let articles = [uniqueArticle]
        let viewModel = SearchArticlesPresenter.map(articles, keyword: "keyword", pageNumber: 1)

        XCTAssertEqual(viewModel.articles, articles)
        XCTAssertEqual(viewModel.pageNumber, 1)
        XCTAssertEqual(viewModel.keyword, "keyword")
    }
}
