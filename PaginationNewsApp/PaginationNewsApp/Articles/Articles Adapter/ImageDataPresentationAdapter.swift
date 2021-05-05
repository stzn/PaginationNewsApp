//
//  ArticlesLoaderPresentationAdapter.swift
//  PaginationNews
//

//

import Combine
import Foundation
import PaginationNews
import PaginationNewsiOS

final class ImageDataPresentationAdapter<View: ContentView> {
	private let loader: () -> AnyPublisher<Data, Error>
	private var cancellable: Cancellable?
	var presenter: Presenter<Data, View>?

	init(loader: @escaping () -> AnyPublisher<Data, Error>) {
		self.loader = loader
	}

	func loadContent() {
		presenter?.didStartLoading()

		cancellable = loader()
			.dispatchOnMainQueue()
			.sink(
				receiveCompletion: { [weak self] completion in
					switch completion {
					case .finished: break

					case let .failure(error):
						self?.presenter?.didFinishLoading(with: error)
					}
				}, receiveValue: { [weak self] articles in
					self?.presenter?.didFinishLoading(articles)
				})
	}
}

extension ImageDataPresentationAdapter: ArticleCellControllerDelegate {
	func didRequestImage() {
		loadContent()
	}

	func didCancelImageRequest() {
		cancellable?.cancel()
		cancellable = nil
	}
}
