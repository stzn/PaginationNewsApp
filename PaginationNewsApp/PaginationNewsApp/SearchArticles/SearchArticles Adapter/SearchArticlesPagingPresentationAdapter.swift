//
//  SearchArticlesPagingPresentationAdapter.swift
//  PaginationNewsApp
//
//  Created by Shinzan Takata on 2021/01/02.
//

import Combine
import Foundation
import PaginationNews
import PaginationNewsiOS

private struct PageState {
    var isLoading: Bool
    var isLast: Bool
    var pageNumber: Int
    var keyword: String

    var nextPage: Int? {
        isLast ? nil : pageNumber + 1
    }

    static var initial: Self = .init(isLoading: false, isLast: false, pageNumber: 0, keyword: "")
}

final class SearchArticlesPagingPresentationAdapter<View: ContentView> {
    private let loader: (Int, String) -> AnyPublisher<([Article], Int) , Error>
    private var cancellable: Cancellable?
    var presenter: Presenter<([Article], Int), View>?
    private var pageState: PageState = .initial
    private let perPageCount: Int

    init(loader: @escaping (Int, String) -> AnyPublisher<([Article], Int), Error>,
         perPageCount: Int) {
        self.loader = loader
        self.perPageCount = perPageCount
    }

    func loadContent() {
        guard !pageState.isLast, !pageState.isLoading,
              let nextPage = pageState.nextPage,
              !pageState.keyword.isEmpty else {
            return
        }
        presenter?.didStartLoading()

        cancellable = loader(nextPage, pageState.keyword)
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

extension SearchArticlesPagingPresentationAdapter {
    func didRequestPage() {
        loadContent()
    }
}

extension SearchArticlesPagingPresentationAdapter {
    func didRequestRefresh(_ keyword: String) {
        pageState = .initial
        pageState.keyword = keyword
        loadContent()
    }
}
