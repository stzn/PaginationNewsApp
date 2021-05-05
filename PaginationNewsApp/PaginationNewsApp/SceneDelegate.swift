//
//  SceneDelegate.swift
//  PaginationNews
//

//

import Combine
import CoreData
import UIKit
import os
import PaginationNews

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()

	private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
		label: "shiz.sample.scheduler.queue",
		qos: .userInitiated,
		attributes: .concurrent
	).eraseToAnyScheduler()

	private lazy var logger = Logger(subsystem: "shiz.sample.PaginationNews", category: "main")

	private lazy var articlesCacheStore: ArticlesCacheStore = {
		do {
			return try CoreDataArticlesCacheStore(
				storeURL: NSPersistentContainer
					.defaultDirectoryURL()
					.appendingPathComponent("articles-store.sqlite"))
		} catch {
			assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
			logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
			return NullStore()
		}
	}()

	private lazy var localArticlesManager: LocalArticlesManager = {
		LocalArticlesManager(store: articlesCacheStore, currentDate: Date.init)
	}()

	private lazy var imageDataCacheBaseDirectory: URL = {
		let url = FileManager.default
			.urls(for: .cachesDirectory, in: .userDomainMask)[0]
			.appendingPathComponent("imageData")
		if !FileManager.default.fileExists(atPath: url.path) {
			try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		}
		return url
	}()

	private lazy var imageDataStore: ArticleImageDataCacheStore = {
		FileArticleImageDataCacheStore(baseDirectroy: imageDataCacheBaseDirectory)
	}()

	private lazy var localArticleImageDataManager: LocalArticleImageDataManager = {
		LocalArticleImageDataManager(store: imageDataStore)
	}()

	convenience init(httpClient: HTTPClient) {
		self.init()
		self.httpClient = httpClient
	}

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }

		window = UIWindow(windowScene: scene)
		configureWindow()
	}

	private func configureWindow() {
		window?.rootViewController = tabBarController
		window?.makeKeyAndVisible()
	}

	private var tabBarController: UITabBarController {
		let tabBarController = UITabBarController()
		tabBarController.viewControllers = [
			UINavigationController(rootViewController: articlesViewController),
			UINavigationController(rootViewController: searchArticlesViewController),
		]
		return tabBarController
	}

	private var articlesViewController: UIViewController {
		let viewController = ArticlesUIComposer.articlesComposedWith(
			articlesLoader: self.makeRemoteArticlesLoaderWithFallback(category:page:),
			imageLoader: self.makeRemoteArticleImageDataLoaderWithFallback(article:))
		viewController.tabBarItem = UITabBarItem(title: ArticlesPresenter.title, image: UIImage(systemName: "clock.fill"), tag: 0)
		return viewController
	}

	private func makeRemoteArticlesLoaderWithFallback(category: TopHeadlineCategory, page: Int) -> AnyPublisher<[Article], Error> {
		let remoteURL = TopHeadlineEndpoint.get(category: category, page: page).url()
		return page == 1 ?
			makeRemoteArticlesLoader(url: remoteURL)
			.fallback(to: localArticlesManager.loadPublisher)
			.caching(to: { [localArticlesManager] in
				try? localArticlesManager.save($0)
			})
			: localArticlesManager.loadPublisher()
			.zip(makeRemoteArticlesLoader(url: remoteURL))
			.map { $0 + $1 }
			.caching(to: { [localArticlesManager] in
				try? localArticlesManager.save($0)
			})
	}

	private func makeRemoteArticlesLoader(url: URL) -> AnyPublisher<[Article], Error> {
		httpClient
			.send(request: .init(url: url))
			.tryMap(ArticlesMapper.map)
			.eraseToAnyPublisher()
	}

	private func makeRemoteArticleImageDataLoaderWithFallback(article: Article) -> AnyPublisher<Data, Error> {
		struct NoURLError: Error {}
		guard let url = article.urlToImage else {
			return Fail(error: NoURLError()).eraseToAnyPublisher()
		}
		return localArticleImageDataManager
			.loadPublisher(for: article)
			.fallback(to: { [makeRemoteImageLoader, localArticleImageDataManager] in
				makeRemoteImageLoader(url)
					.caching(to: { data in
						try? localArticleImageDataManager.save(for: article, data)
					})
			})
			.subscribe(on: scheduler)
			.eraseToAnyPublisher()
	}

	private func makeRemoteImageLoader(url: URL) -> AnyPublisher<Data, Error> {
		return
			httpClient
				.send(request: .init(url: url))
				.tryMap(ArticleImageDataMapper.map)
				.eraseToAnyPublisher()
	}

	private var searchArticlesViewController: UIViewController {
		let viewController = SearchArticlesUIComposer.articlesComposedWith(
			articlesLoader: self.makeRemoteSearchArticlesLoaderWithFallback(keyword:page:),
			imageLoader: self.makeRemoteArticleImageDataLoaderWithFallback(article:))
		viewController.tabBarItem = UITabBarItem(title: SearchArticlesPresenter.title, image: UIImage(systemName: "magnifyingglass"), tag: 1)
		return viewController
	}

	private func makeRemoteSearchArticlesLoaderWithFallback(keyword: String, page: Int) -> AnyPublisher<[Article], Error> {
		let remoteURL = SearchArticlesEndpoint.get(keyword: keyword, page: page).url()
		return page == 1 ?
			makeRemoteSearchArticlesLoader(url: remoteURL)
			.fallback(to: localArticlesManager.loadPublisher)
			.caching(to: { [localArticlesManager] in
				try? localArticlesManager.save($0)
			})
			.subscribe(on: scheduler)
			.eraseToAnyPublisher()
			: localArticlesManager.loadPublisher()
			.zip(makeRemoteSearchArticlesLoader(url: remoteURL))
			.map { $0 + $1 }
			.caching(to: { [localArticlesManager] in
				try? localArticlesManager.save($0)
			})
			.subscribe(on: scheduler)
			.eraseToAnyPublisher()
	}

	private func makeRemoteSearchArticlesLoader(url: URL) -> AnyPublisher<[Article], Error> {
		return httpClient
			.send(request: .init(url: url))
			.tryMap(ArticlesMapper.map)
			.eraseToAnyPublisher()
	}
}
