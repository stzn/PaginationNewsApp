//
//  SearchArticlesSnapshotTests.swift
//  PaginationNewsiOSTests
//
//  Created by Shinzan Takata on 2020/10/11.
//

import XCTest
@testable import PaginationNews
import PaginationNewsiOS

class SearchArticlesSnapshotTests: XCTestCase {
	func test_articlesWithContent() {
		let sut = makeSUT()

		let controllers = sut.cellControllers(articlesWithContent())
		sut.setSearchText("test")
		sut.display(controllers)
		sut.view.enforceLayoutCycle()

		let navigationController = UINavigationController(rootViewController: sut)
		assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .light)), named: "SEARCH_ARTICLES_light")
		assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .dark)), named: "SEARCH_ARTICLES_dark")
	}

	func test_articlesNoKeyword() {
		let sut = makeSUT()

		sut.displayEmpty("Please input keyword in search bar")

		sut.view.enforceLayoutCycle()

		let navigationController = UINavigationController(rootViewController: sut)
		assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .light)), named: "SEARCH_ARTICLES_NO_KEYWORD_light")
		assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .dark)), named: "SEARCH_ARTICLES_NO_KEYWORD_dark")
	}

	func test_articlesNoMatchedData() {
		let sut = makeSUT()

		sut.setSearchText("test")
		sut.displayEmpty("No matched data")

		sut.view.enforceLayoutCycle()

		let navigationController = UINavigationController(rootViewController: sut)
		assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .light)), named: "SEARCH_ARTICLES_NO_MATCHED_light")
		assert(snapshot: navigationController.snapshot(for: .iPhone8(style: .dark)), named: "SEARCH_ARTICLES_NO_MATCHED_dark")
	}

	// MARK: - Helpers

	private func makeSUT() -> SearchArticlesViewController {
		let stub = ArticlesStub()
		let bundle = Bundle(for: SearchArticlesViewController.self)
		let storyboard = UIStoryboard(name: "SearchArticlesViewController", bundle: bundle)
		let listViewController = ListViewController(onRefresh: stub.didRequestRefresh, onPageRequest: stub.didRequestPage)
		guard let controller = (storyboard.instantiateInitialViewController { coder in
			SearchArticlesViewController(coder: coder,
			                             listViewController: listViewController,
			                             didInput: { _ in })
		}) else {
			fatalError()
		}
		controller.title = SearchArticlesPresenter.title

		controller.loadViewIfNeeded()
		listViewController.loadViewIfNeeded()
		return controller
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

private extension SearchArticlesViewController {
	func cellControllers(_ stubs: [ArticleStub]) -> [CellController] {
		stubs.map { stub in
			let cellController = ArticleCellController(
				viewModel: stub.viewModel,
				delegate: stub)
			stub.controller = cellController
			return CellController(id: UUID(), dataSource: cellController, delegate: cellController, dataSourcePrefetching: cellController)
		}
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
