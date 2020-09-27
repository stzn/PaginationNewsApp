//
//  ArticlesSnapshotTests.swift
//  PaginationNewsiOSTests
//
//

import XCTest
@testable import PaginationNews
@testable import PaginationNewsiOS

class ArticlesSnapshotTests: XCTestCase {
    func test_emptyArticles() {
        let sut = makeSUT()

        sut.append(emptyArticles())

        let navigationController = UINavigationController(rootViewController: sut)
        assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_ARTICLES_light")
        assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_ARTICLES_dark")
    }

    func test_articlesWithContent() {
        let sut = makeSUT()

        sut.display(articlesWithContent())
        sut.view.enforceLayoutCycle()

        let navigationController = UINavigationController(rootViewController: sut)
        assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .light)), named: "ARTICLES_light")
        assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .dark)), named: "ARTICLES_dark")
    }

    func test_articlesWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(
            snapshot: sut.snapshot(for: .iPhone8(style: .light)),
            named: "ARTICLES_WITH_ERROR_MESSAGE_light")
        assert(
            snapshot: sut.snapshot(for: .iPhone8(style: .dark)),
            named: "ARTICLES_WITH_ERROR_MESSAGE_dark")
    }

    // MARK: - Helpers

    private func makeSUT() -> ArticlesViewController {
        let stub = ArticlesStub()
        let bundle = Bundle(for: ArticlesViewController.self)
        let storyboard = UIStoryboard(name: "ArticlesViewController", bundle: bundle)
        guard let controller = (storyboard.instantiateInitialViewController { coder in
            ArticlesViewController(coder: coder,
                                   pagingDelegate: stub,
                                   refreshDelegate: stub)
        }) else {
            fatalError()
        }
        controller.title = ArticlesPresenter.title

        controller.loadViewIfNeeded()
        controller.collectionView.showsVerticalScrollIndicator = false
        controller.collectionView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func emptyArticles() -> [ArticleCellController] {
        return []
    }

    private func articlesWithContent() -> [ArticleStub] {
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

private extension Date {
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}

private extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}

private extension ArticlesViewController {
    func display(_ stubs: [ArticleStub]) {
        let cells: [ArticleCellController] = stubs.map { stub in
            let cellController = ArticleCellController(
                viewModel: stub.viewModel,
                errorImage: UIImage.make(withColor: .white),
                delegate: stub)
            stub.controller = cellController
            return cellController
        }
        append(cells)
    }
}

// Nothing to do
private final class ArticlesStub: ArticlesPagingViewControllerDelegate, ArticlesViewControllerDelegate {
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
            controller?.display(.init(message: "any error"))
            return
        }
        controller?.display(image)
        controller?.display(.init(message: nil))
    }

    func didCancelImageRequest() {}
}

