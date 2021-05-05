//
//  ArticlesPagingPresentationAdapter.swift
//  PaginationNews
//
//

import Combine
import Foundation
import PaginationNews
import PaginationNewsiOS

private struct PageState {
	var isLoading: Bool
	var isLast: Bool
	var pageNumber: Int
	var category: TopHeadlineCategory

	var nextPage: Int? {
		isLast ? nil : pageNumber + 1
	}

	static var initial: Self = .init(isLoading: false, isLast: false, pageNumber: 0, category: .all)
}

final class ArticlesPagingPresentationAdapter<View: ContentView> {
	private let loader: (TopHeadlineCategory, Int) -> AnyPublisher<([Article], Int), Error>
	private var cancellable: Cancellable?
	var presenter: Presenter<([Article], Int), View>?
	private var pageState: PageState = .initial
	private let perPageCount: Int

	init(loader: @escaping (TopHeadlineCategory, Int) -> AnyPublisher<([Article], Int), Error>,
	     perPageCount: Int) {
		self.loader = loader
		self.perPageCount = perPageCount
	}

	func loadContent() {
		guard !pageState.isLast, !pageState.isLoading,
		      let nextPage = pageState.nextPage else {
			return
		}
		presenter?.didStartLoading()

		cancellable = loader(pageState.category, nextPage)
			.dispatchOnMainQueue()
			.sink(
				receiveCompletion: { [weak self] completion in
					switch completion {
					case .finished: break

					case let .failure(error):
						self?.pageState = .initial
						self?.presenter?.didFinishLoading(with: error)
					}
				}, receiveValue: { [weak self] articles, totalResults in
					guard let self = self else {
						return
					}
					if totalResults <= self.perPageCount * nextPage {
						self.pageState.isLast = true
					}
					self.pageState.pageNumber = nextPage
					self.presenter?.didFinishLoading((articles, nextPage))
				})
	}
}

extension ArticlesPagingPresentationAdapter {
	func didRequestPage() {
		loadContent()
	}
}

extension ArticlesPagingPresentationAdapter {
	func didRequestRefresh(_ category: TopHeadlineCategory) {
		pageState = .initial
		pageState.category = category
		loadContent()
	}
}
