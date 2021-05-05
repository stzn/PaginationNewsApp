//
//  SearchArticlesViewController+TestHelpers.swift
//  PaginationNewsAppTests
//
//  Created by Shinzan Takata on 2021/01/02.
//

import UIKit
@testable import PaginationNewsiOS

extension SearchArticlesViewController {
	func simulateInputSearchText(_ input: String) {
		searchBar.delegate?.searchBar?(searchBar, textDidChange: input)
	}

	func loadViewIfNeededWithSearchText(_ keyword: String = "any") {
		loadViewIfNeeded()
		simulateInputSearchText(keyword)
	}

	func simulateUserInitiatedArticlesReload() {
		listViewController.simulateUserInitiatedArticlesReload()
	}

	func simulateRetryOnError() {
		listViewController.simulateRetryOnError()
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
}
