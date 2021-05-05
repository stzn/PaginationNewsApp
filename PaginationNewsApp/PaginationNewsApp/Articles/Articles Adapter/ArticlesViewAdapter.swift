//
//  ArticlesViewAdapter.swift
//  PaginationNews
//

//

import Combine
import UIKit
import PaginationNews
import PaginationNewsiOS

final class ArticlesViewAdapter: ContentView {
	private weak var controller: ListViewController?
	private let imageLoader: (Article) -> AnyPublisher<Data, Error>
	private typealias PresentationAdapter = ImageDataPresentationAdapter<WeakReference<ArticleCellController>>

	init(controller: ListViewController, imageLoader: @escaping (Article) -> AnyPublisher<Data, Error>) {
		self.controller = controller
		self.imageLoader = imageLoader
	}

	func display(_ viewModel: ArticlesViewModel) {
		let controllers = viewModel.articles.map(map)
		controller?.set(controllers)
	}

	private struct NoImageError: Error {}

	private func map(_ model: Article) -> CellController {
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

extension UIImage {
	struct InvalidData: Error {}

	static func tryMap(_ data: Data) throws -> UIImage {
		if let image = UIImage(data: data) {
			return image
		} else {
			throw InvalidData()
		}
	}
}

private final class PublishedAtDateFormatter {
	static var formatter: RelativeDateTimeFormatter = {
		let formatter = RelativeDateTimeFormatter()
		return formatter
	}()

	static func format(from date: Date, relativeTo standard: Date = Date()) -> String {
		formatter.localizedString(for: date, relativeTo: standard)
	}
}
