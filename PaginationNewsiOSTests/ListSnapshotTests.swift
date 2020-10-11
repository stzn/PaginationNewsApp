//
//  ListSnapshotTests.swift
//  PaginationNewsiOSTests
//
//  Created by Shinzan Takata on 2020/10/11.
//

import XCTest
@testable import PaginationNews
@testable import PaginationNewsiOS

class ListSnapshotTests: XCTestCase {
    func test_emptyList() {
        let sut = makeSUT()

        sut.set(emptyList())

        let navigationController = UINavigationController(rootViewController: sut)
        assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
    }

    func test_listWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message", retryButtonTitle: "Retry"))

        assert(
            snapshot: sut.snapshot(for: .iPhone8(style: .light)),
            named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(
            snapshot: sut.snapshot(for: .iPhone8(style: .dark)),
            named: "LIST_WITH_ERROR_MESSAGE_dark")
    }

    // MARK: - Helpers

    private func makeSUT() -> ArticlesViewController {
        let stub = ArticlesStub()
        let bundle = Bundle(for: ArticlesViewController.self)
        let storyboard = UIStoryboard(name: "ArticlesViewController", bundle: bundle)
        guard let controller = (storyboard.instantiateInitialViewController { coder in
            ArticlesViewController(coder: coder,
                                   onRefresh: stub.didRequestRefresh,
                                   onPageRequest: stub.didRequestPage)
        }) else {
            fatalError()
        }
        controller.title = ArticlesPresenter.title

        controller.loadViewIfNeeded()
        controller.collectionView.showsVerticalScrollIndicator = false
        controller.collectionView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func emptyList() -> [ArticleCellController] {
        return []
    }

    private func listWithContent() -> [ArticleStub] {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        return [
            ArticleStub(
                article: Article(id: UUID(),
                                 author: "author0",
                                 title: "title0",
                                 description: String(repeating: "description0", count: 10),
                                 linkString: "https://any-link0.com",
                                 urlToImage: anyURL,
                                 publishedAt: now.adding(days: -1, calendar: calendar),
                                 sourceName: "source0"
                ),
                image: UIImage.make(withColor: .red),
                calendar: calendar, locale: locale
            ),
            ArticleStub(
                article: Article(id: UUID(),
                                 author: "author1",
                                 title: "title1",
                                 description: String(repeating: "description1", count: 10),
                                 linkString: "https://any-link1.com",
                                 urlToImage: anyURL,
                                 publishedAt: now.adding(minutes: -5, calendar: calendar),
                                 sourceName: "source1"
                ),
                image: UIImage.make(withColor: .green),
                calendar: calendar, locale: locale
            ),
        ]
    }

    private func createLinkString(from linkString: String) -> NSAttributedString {
        .init(string: linkString,
              attributes: [NSAttributedString.Key.link: linkString])
    }

    private var anyURL: URL {
        URL(string: "https://any-url.com")!
    }
}

private extension ArticlesViewController {
    func display(_ stubs: [ArticleStub]) {
        let cells: [ArticleCellController] = stubs.map { stub in
            let cellController = ArticleCellController(
                viewModel: stub.viewModel,
                delegate: stub)
            stub.controller = cellController
            return cellController
        }
        set(cells)
    }
}

// Nothing to do
private final class ArticlesStub {
    func didRequestPage() {}
    func didRequestRefresh() {}
}

private final class ArticleStub: ArticleCellControllerDelegate {
    let viewModel: ArticleViewModel
    let image: UIImage?
    weak var controller: ArticleCellController?

    init(article: Article, image: UIImage?,
         calendar: Calendar = .current, locale: Locale = .current) {
        self.viewModel = ArticlePresenter.map(article, calendar: calendar, locale: locale)
        self.image = image
    }

    func didRequestImage() {
        controller?.display(.init(isLoading: false))

        guard let image = image else {
            controller?.display(.init(message: "any error", retryButtonTitle: "Retry"))
            return
        }
        controller?.display(image)
        controller?.display(.init(message: nil, retryButtonTitle: nil))
    }

    func didCancelImageRequest() {}
}

