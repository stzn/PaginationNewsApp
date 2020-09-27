//
//  ArticlePresenterTests.swift
//  PaginationNewsTests
//

//

import XCTest
@testable import PaginationNews

class ArticlePresenterTests: XCTestCase {
    func test_map_createsViewModel() {
        let article = uniqueArticle

        let viewModel = ArticlePresenter.map(article)

        XCTAssertEqual(viewModel.description, article.description)
        XCTAssertEqual(viewModel.title, article.title)
        XCTAssertEqual(viewModel.author, article.author)
        XCTAssertEqual(viewModel.id, article.id)
        XCTAssertEqual(viewModel.link, createLink(article.linkString ?? ""))
    }

    private func createLink(_ link: String) -> NSAttributedString {
        NSMutableAttributedString(
            string: link,
            attributes: [NSAttributedString.Key.link: link])
    }
}
