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

        typealias ArticlesLoaderResult = Swift.Result<([Article], Int), Error>
        typealias ArticlesLoaderPublisher = AnyPublisher<([Article], Int), Error>

        func loadPublisher(_ page: Int) -> ArticlesLoaderPublisher {
            Deferred {
                Future(self.load)
            }
            .eraseToAnyPublisher()
        }

        private var articlesRequests: [(ArticlesLoaderResult) -> Void] = []

        var loadArticlesCallCount: Int {
            return articlesRequests.count
        }

        func load(completion: @escaping (ArticlesLoaderResult) -> Void) {
            articlesRequests.append(completion)
        }

        func completeArticlesLoading(with articles: [Article] = [], totalResults: Int = 20, at index: Int = 0) {
            articlesRequests[index](.success((articles, totalResults)))
        }

        func completeArticlesLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            articlesRequests[index](.failure(error))
        }

        // MARK: - ArticlesImageDataLoader

        typealias ArticlesImageDataLoaderResult = Swift.Result<Data, Error>
        typealias ArticlesImageDataLoaderPublisher = AnyPublisher<Data, Error>

        func loadImageDataPublisher(from url: URL) -> ArticlesImageDataLoaderPublisher {
            var cancellable: AnyCancellable?

            return Deferred {
                Future { completion in
                    cancellable = self.loadImageData(from: url, completion: completion)
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

        func loadImageData(from url: URL, completion: @escaping (ArticlesImageDataLoaderResult) -> Void) -> AnyCancellable {
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
