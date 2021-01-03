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

final class SearchArticlesViewAdapter: ContentView {
    private weak var controller: SearchArticlesViewController?
    private let imageLoader: (URL) -> AnyPublisher<Data, Error>
    private typealias PresentationAdapter = ImageDataPresentationAdapter<WeakReference<ArticleCellController>>

    init(controller: SearchArticlesViewController, imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>) {
        self.controller = controller
        self.imageLoader = imageLoader
        controller.display([], keyword: "", pageNumber: 1)
    }

    func display(_ viewModel: SearchArticlesViewModel) {
        guard let controller = controller else {
            return
        }
        let controllers = viewModel.articles.map(map)
        controller.display(controllers, keyword: viewModel.keyword, pageNumber: viewModel.pageNumber)
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
}
