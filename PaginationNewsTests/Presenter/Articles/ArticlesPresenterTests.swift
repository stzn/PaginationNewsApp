//
//  ArticlesPresenterTests.swift
//  PaginationNewsTests
//

//

import XCTest
import PaginationNews

class ArticlesPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ArticlesPresenter.title, localized("VIEW_TITLE"))
    }

    func test_map_createsViewModel() {
        let articles = [uniqueArticle]
        let viewModel = ArticlesPresenter.map(articles, pageNumber: 1)

        XCTAssertEqual(viewModel.articles, articles)

    }

    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Articles"
        let bundle = Bundle(for: ArticlesPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

}
