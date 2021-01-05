//
//  ListViewController+TestHelpers.swift
//  PaginationNewsAppTests
//
//

import UIKit
import PaginationNews
@testable import PaginationNewsiOS

extension ArticlesViewController {
    func simulateUserInitiatedArticlesReload() {
        refreshControl.simulatePullToRefresh()
    }

    @discardableResult
    func simulateArticleViewVisible(at index: Int) -> ArticleCell? {
        listViewController.simulateArticleViewVisible(at: index)
    }

    @discardableResult
    func simulateArticleViewNotVisible(at row: Int) -> ArticleCell? {
        listViewController.simulateArticleViewNotVisible(at: row)
    }

    func simulateArticleViewNearVisible(at row: Int) {
        listViewController.simulateArticleViewNearVisible(at: row)
    }

    func simulateArticleViewNotNearVisible(at row: Int) {
        listViewController.simulateArticleViewNotNearVisible(at: row)
    }

    func simulateUserScrollToBottom() {
        listViewController.simulateUserScrollToBottom()
    }

    func simulateArticleViewDidSelectRow(at row: Int) {
        listViewController.simulateArticleViewDidSelectRow(at: row)
    }

    func simulateRetryOnError() {
        listViewController.simulateRetryOnError()
    }

    func renderedArticleImageData(at index: Int) -> Data? {
        listViewController.renderedArticleImageData(at: index)
    }

    var errorMessage: String? {
        return errorView.errorLabel.text
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl.isRefreshing == true
    }

    func numberOfRenderedArticleViews() -> Int {
        listViewController.numberOfRenderedArticleViews()
    }

    func articleView(at row: Int) -> UICollectionViewCell? {
        listViewController.articleView(at: row)
    }

    private var refreshControl: UIRefreshControl {
        listViewController.refreshControl
    }

    var errorView: ErrorUIView {
        listViewController.errorView
    }

    // It's difficule to use UIAlertController.
    // So, call closure directly.
    func simulateSelcetCategory(_ category: TopHeadlineCategory) {
        categoryViewController.onSelect(category)
    }
}
