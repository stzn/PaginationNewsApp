//
//  ListViewController+TestHelpers.swift
//  PaginationNewsAppTests
//
//  Created by Shinzan Takata on 2021/01/04.
//

import UIKit
@testable import PaginationNewsiOS

extension ListViewController {
    func simulateUserInitiatedArticlesReload() {
        refreshControl.simulatePullToRefresh()
    }

    @discardableResult
    func simulateArticleViewVisible(at index: Int) -> ArticleCell? {
        let view = articleView(at: index) as? ArticleCell

        let delegate = collectionView.delegate
        let index = IndexPath(item: index, section: articlesSection)
        delegate?.collectionView?(collectionView, willDisplay: view!, forItemAt: index)

        return view
    }

    @discardableResult
    func simulateArticleViewNotVisible(at row: Int) -> ArticleCell? {
        let view = simulateArticleViewVisible(at: row)

        let delegate = collectionView.delegate
        let index = IndexPath(row: row, section: articlesSection)
        delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: index)

        return view
    }

    func simulateArticleViewNearVisible(at row: Int) {
        let ds = collectionView.prefetchDataSource
        let index = IndexPath(row: row, section: articlesSection)
        ds?.collectionView(collectionView, prefetchItemsAt: [index])
    }

    func simulateArticleViewNotNearVisible(at row: Int) {
        simulateArticleViewNearVisible(at: row)

        let ds = collectionView.prefetchDataSource
        let index = IndexPath(row: row, section: articlesSection)
        ds?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [index])
    }

    func simulateUserScrollToBottom() {
        let scrollView = DraggingScrollView()
        scrollView.contentOffset.y = 1000
        let delegate = collectionView.delegate
        delegate?.scrollViewDidScroll?(scrollView)
    }

    func simulateArticleViewDidSelectRow(at row: Int) {
        let delegate = collectionView.delegate
        let index = IndexPath(row: row, section: articlesSection)
        delegate?.collectionView?(collectionView, didSelectItemAt: index)
    }

    func simulateRetryOnError() {
        errorView.retryButton.simulateTap()
    }

    func renderedArticleImageData(at index: Int) -> Data? {
        return simulateArticleViewVisible(at: index)?.renderedImage
    }

    var errorMessage: String? {
        return errorView.errorLabel.text
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl.isRefreshing == true
    }

    func numberOfRenderedArticleViews() -> Int {
        return collectionView.numberOfSections == 0 ?
            0 : collectionView.numberOfItems(inSection: articlesSection)
    }

    func articleView(at row: Int) -> UICollectionViewCell? {
        guard numberOfRenderedArticleViews() > row else {
            return nil
        }
        let ds = collectionView.dataSource
        let index = IndexPath(row: row, section: articlesSection)
        return ds?.collectionView(collectionView, cellForItemAt: index)
    }

    private var articlesSection: Int {
        return 0
    }
}

private class DraggingScrollView: UIScrollView {
    override var isDragging: Bool {
        true
    }
}
