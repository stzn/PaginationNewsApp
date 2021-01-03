//
//  SearchArticlesViewController+TestHelpers.swift
//  PaginationNewsAppTests
//
//  Created by Shinzan Takata on 2021/01/02.
//

import Foundation
import PaginationNewsiOS

extension SearchArticlesViewController {
    func simulateInputSearchText(_ input: String) {
        searchBar.delegate?.searchBar?(searchBar, textDidChange: input)
    }

    func loadViewIfNeededWithSearchText(_ keyword: String = "any") {
        loadViewIfNeeded()
        simulateInputSearchText(keyword)
    }

    func simulateUserInitiatedArticlesReload() {
        list.simulateUserInitiatedArticlesReload()
    }

    func simulateRetryOnError() {
        list.simulateRetryOnError()
    }
}
