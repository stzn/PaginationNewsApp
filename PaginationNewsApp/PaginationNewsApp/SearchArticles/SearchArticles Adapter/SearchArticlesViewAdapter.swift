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
	private weak var controller: SearchArticlesViewController?
	private let imageLoader: (Article) -> AnyPublisher<Data, Error>
	private typealias PresentationAdapter = ImageDataPresentationAdapter<WeakReference<ArticleCellController>>

	init(controller: SearchArticlesViewController, imageLoader: @escaping (Article) -> AnyPublisher<Data, Error>) {
		self.controller = controller
		self.imageLoader = imageLoader
		controller.displayEmpty(EmptyReason.noKeyword.message)
	}

	func display(_ viewModel: SearchArticlesViewModel) {
		guard let controller = controller else {
			return
		}
		let controllers = viewModel.articles.map(map)
		controller.display(controllers)
		if controllers.isEmpty {
			let reason: EmptyReason = viewModel.keyword.isEmpty ? .noKeyword : .noData
			controller.displayEmpty(reason.message)
		}
	}

	private struct NoImageError: Error {}

	func map(_ model: Article) -> CellController {
		let adapter = PresentationAdapter(loader: { self.imageLoader(model) })
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
