//
//  ArticlePresenterTests.swift
//  PaginationNewsTests
//

//

import XCTest
@testable import PaginationNews

class ArticlePresenterTests: XCTestCase {
    func test_map_createsViewModel() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let id0 = UUID()
        let id1 = UUID()
        let articles = [
            Article(id: id0,
                    author: "author0",
                    title: "title0",
                    description: "description0",
                    linkString: "https://any-link0.com",
                    urlToImage: anyURL,
                    publishedAt: now.adding(days: -1, calendar: calendar),
                    sourceName: "source0"
            ),
            Article(id: id1,
                    author: "author1",
                    title: "title1",
                    description: "description1",
                    linkString: "https://any-link1.com",
                    urlToImage: anyURL,
                    publishedAt: now.adding(minutes: -5, calendar: calendar),
                    sourceName: "source1"
            ),
        ]

        let viewModels = articles.map {
            ArticlePresenter.map($0, calendar: calendar, locale: locale)
        }

        XCTAssertEqual(viewModels, [
            ArticleViewModel(id: id0,
                    author: "author0",
                    title: "title0",
                    publishedAt: "1 day ago",
                    link: createLink("https://any-link0.com"),
                    description: "description0"
            ),
            ArticleViewModel(id: id1,
                    author: "author1",
                    title: "title1",
                    publishedAt: "5 minutes ago",
                    link: createLink("https://any-link1.com"),
                    description: "description1"
            ),
        ])
    }

    private func createLink(_ link: String) -> NSAttributedString {
        NSMutableAttributedString(
            string: link,
            attributes: [NSAttributedString.Key.link: link])
    }
}
