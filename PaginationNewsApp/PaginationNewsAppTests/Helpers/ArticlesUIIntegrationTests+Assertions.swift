//
//  ArticlesUIIntegrationTests+Assertions.swift
//  PaginationNewsAppTests
//
//

import XCTest
@testable import PaginationNews
import PaginationNewsiOS

extension ArticlesUIIntegrationTests {

    func assertThat(_ sut: ArticlesViewController, isRendering feed: [Article], file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()

        guard sut.numberOfRenderedArticleViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedArticleViews()) instead.", file: file, line: line)
        }

        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }

        executeRunLoopToCleanUpReferences()
    }

    func assertThat(_ sut: ArticlesViewController, hasViewConfiguredFor article: Article,
                    at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.articleView(at: index)

        guard let cell = view as? ArticleCell else {
            return XCTFail("Expected \(ArticleCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        XCTAssertEqual(cell.titleText, article.title, "Expected title text to be \(String(describing: article.title)) for view at index (\(index)", file: file, line: line)

        XCTAssertEqual(cell.authorText, article.author, "Expected author text to be \(String(describing: article.author)) for view at index (\(index)", file: file, line: line)

        XCTAssertEqual(cell.linkText, article.linkString, "Expected author text to be \(String(describing: article.linkString)) for view at index (\(index)", file: file, line: line)

        XCTAssertEqual(cell.publishedAtText, PublishedAtDateFormatter.format(from: article.publishedAt), "Expected author text to be \(String(describing: article.linkString)) for view at index (\(index)", file: file, line: line)

        XCTAssertEqual(cell.descriptionText, article.description, "Expected description text to be \(String(describing: article.description)) for view at index (\(index)", file: file, line: line)
    }

    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }

}
