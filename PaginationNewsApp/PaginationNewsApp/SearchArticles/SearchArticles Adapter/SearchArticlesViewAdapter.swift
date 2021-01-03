//
//  SearchArticlesViewAdapter.swift
//  PaginationNewsApp
//
//  Created by Shinzan Takata on 2021/01/03.
//

import Combine
import UIKit
import PaginationNews
import PaginationNewsiOS

private enum EmptyReason {
    case noKeyword
    case noData

    var message: String {
        switch self {
        case .noKeyword: return SearchArticlesPresenter.noKeywordMessage
        case .noData: return SearchArticlesPresenter.noMatchedDataMessage
        }
    }
}

final class SearchArticlesViewAdapter: ContentView {
    private(set) lazy var emptyView = EmptyUIView()

    private weak var controller: SearchArticlesViewController?
    private let imageLoader: (URL) -> AnyPublisher<Data, Error>
    private typealias PresentationAdapter = ImageDataPresentationAdapter<WeakReference<ArticleCellController>>

    init(controller: SearchArticlesViewController, imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.showEmpty(reason: .noKeyword, on: controller)
    }

    func display(_ viewModel: SearchArticlesViewModel) {
        guard let controller = controller else {
            return
        }

        let controllers = viewModel.articles.map(map)
        switch (viewModel.pageNumber, controllers.isEmpty, viewModel.keyword.isEmpty) {
        case (1, true, true):
            showEmpty(reason: .noKeyword, on: controller)
            controller.listViewController.set(controllers)
        case (1, true, false):
            showEmpty(reason: .noData, on: controller)
            controller.listViewController.set(controllers)
        case (1, false, _):
            hideEmpty()
            controller.listViewController.set(controllers)
        case (_, true, _), (_, false, _):
            hideEmpty()
            controller.listViewController.append(controllers)
        }
    }

    private struct NoImageError: Error {}

    func map(_ model: Article) -> CellController {
        let adapter = PresentationAdapter { model.urlToImage != nil ?
            self.imageLoader(model.urlToImage!)
            : Fail(error: NoImageError()).eraseToAnyPublisher()
        }
        let view = ArticleCellController(viewModel: ArticlePresenter.map(model),
                                         delegate: adapter)

        adapter.presenter = Presenter(
            contentView: WeakReference(view),
            loadingView: WeakReference(view),
            errorView: WeakReference(view),
            mapper: UIImage.tryMap)

        return CellController(id: UUID(), dataSource: view, delegate: view, dataSourcePrefetching: view)
    }

    private func showEmpty(reason: EmptyReason, on viewController: SearchArticlesViewController) {
        viewController.view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: viewController.searchBar.bottomAnchor),
            emptyView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
        ])
        emptyView.setMessage(reason.message)
    }

    private func hideEmpty() {
        emptyView.setMessage(nil)
        emptyView.removeFromSuperview()
    }
}
