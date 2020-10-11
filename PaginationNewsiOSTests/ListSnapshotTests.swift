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

    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ArticlesViewController", bundle: bundle)
        guard let controller = (storyboard.instantiateInitialViewController { coder in
            ListViewController(coder: coder,
                               onRefresh: { },
                               onPageRequest: { })
        }) else {
            fatalError()
        }
        controller.title = ArticlesPresenter.title

        controller.loadViewIfNeeded()
        controller.collectionView.showsVerticalScrollIndicator = false
        controller.collectionView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func emptyList() -> [CellController] {
        return []
    }
}
