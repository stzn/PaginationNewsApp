//
//  ArticlesUIIntegrationTests+LoaderSpy.swift
//  PaginationNewsAppTests
//
//

import Combine
import Foundation
import PaginationNews

extension ArticlesUIIntegrationTests {
	class LoaderSpy {
		// MARK: - ArticlesLoader

		typealias ArticlesLoaderResult = Swift.Result<[Article], Error>
		typealias ArticlesLoaderPublisher = AnyPublisher<[Article], Error>

		func loadPublisher(_ category: TopHeadlineCategory, _ page: Int) -> ArticlesLoaderPublisher {
			Deferred {
				Future { completion in self.load(category: category, completion: completion) }
			}
			.eraseToAnyPublisher()
		}

		private var articlesRequests: [(category: TopHeadlineCategory, completion: (ArticlesLoaderResult) -> Void)] = []

		var loadArticlesCallCount: Int {
			return articlesRequests.count
		}

		func category(at index: Int) -> TopHeadlineCategory {
			articlesRequests[index].category
		}

		func load(category: TopHeadlineCategory, completion: @escaping (ArticlesLoaderResult) -> Void) {
			articlesRequests.append((category, completion))
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
			let url = article.urlToImage!
			imageRequests.append((url, completion))
			return AnyCancellable { [weak self] in self?.cancelledImageURLs.append(url) }
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
