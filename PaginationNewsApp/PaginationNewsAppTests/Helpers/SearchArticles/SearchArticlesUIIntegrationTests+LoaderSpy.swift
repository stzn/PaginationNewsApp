//
//  SearchArticlesUIIntegrationTests+LoaderSpy.swift
//  PaginationNewsAppTests
//
//  Created by Shinzan Takata on 2021/01/02.
//

import Combine
import Foundation
import PaginationNews

extension SearchArticlesUIIntegrationTests {
	class LoaderSpy {
		// MARK: - ArticlesLoader

		typealias ArticlesLoaderResult = Swift.Result<[Article], Error>
		typealias ArticlesLoaderPublisher = AnyPublisher<[Article], Error>

		func loadPublisher(_ keyword: String, _ page: Int) -> ArticlesLoaderPublisher {
			Deferred {
				Future { self.load(keyword: keyword, completion: $0) }
			}
			.eraseToAnyPublisher()
		}

		private var articlesRequests: [(keyword: String, completion: (ArticlesLoaderResult) -> Void)] = []

		var loadArticlesCallCount: Int {
			return articlesRequests.count
		}

		func keyword(index: Int) -> String {
			articlesRequests[index].keyword
		}

		func load(keyword: String, completion: @escaping (ArticlesLoaderResult) -> Void) {
			articlesRequests.append((keyword, completion))
		}

		func completeArticlesLoading(with articles: [Article] = [], at index: Int = 0) {
			articlesRequests[index].completion(.success(articles))
		}

		func completeArticlesLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			articlesRequests[index].completion(.failure(error))
		}

		// MARK: - ArticlesImageDataLoader

		typealias ArticlesImageDataLoaderResult = Swift.Result<Data, Error>
		typealias ArticlesImageDataLoaderPublisher = AnyPublisher<Data, Error>

		func loadImageDataPublisher(for article: Article) -> ArticlesImageDataLoaderPublisher {
			var cancellable: AnyCancellable?

			return Deferred {
				Future { completion in
					cancellable = self.loadImageData(for: article, completion: completion)
				}
			}
			.handleEvents(receiveCancel: { cancellable?.cancel() })
			.eraseToAnyPublisher()
		}

		private var imageRequests = [(url: URL, completion: (ArticlesImageDataLoaderResult) -> Void)]()

		var loadedImageURLs: [URL] {
			return imageRequests.map { $0.url }
		}

		private(set) var cancelledImageURLs = [URL]()

		func loadImageData(for article: Article, completion: @escaping (ArticlesImageDataLoaderResult) -> Void) -> AnyCancellable {
			imageRequests.append((article.urlToImage!, completion))
			return AnyCancellable { [weak self] in self?.cancelledImageURLs.append(article.urlToImage!) }
		}

		func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
			imageRequests[index].completion(.success(imageData))
		}

		func completeImageLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageRequests[index].completion(.failure(error))
		}
	}
}
