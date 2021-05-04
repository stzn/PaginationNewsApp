//
//  SceneDelegate.swift
//  PaginationNews
//

//

import Combine
import CoreData
import UIKit
import PaginationNews

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()

	private lazy var store: ArticlesCacheStore = {
		try! CoreDataArticlesCacheStore(
			storeURL: NSPersistentContainer
				.defaultDirectoryURL()
				.appendingPathComponent("articles-store.sqlite"))
	}()

	private lazy var localArticlesManager: LocalArticlesManager = {
		LocalArticlesManager(store: store, currentDate: Date.init)
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
			imageLoader: self.makeRemoteImageLoader(url:))
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

	private func makeRemoteImageLoader(url: URL) -> AnyPublisher<Data, Error> {
		return
			httpClient
				.send(request: .init(url: url))
				.tryMap(ArticleImageDataMapper.map)
				.eraseToAnyPublisher()
	}

	private var searchArticlesViewController: UIViewController {
		let viewController = SearchArticlesUIComposer.articlesComposedWith(
			articlesLoader: self.makeRemoteSearchArticlesLoader(keyword:page:),
			imageLoader: self.makeRemoteImageLoader(url:))
		viewController.tabBarItem = UITabBarItem(title: SearchArticlesPresenter.title, image: UIImage(systemName: "magnifyingglass"), tag: 1)
		return viewController
	}

	private func makeRemoteSearchArticlesLoader(keyword: String, page: Int) -> AnyPublisher<[Article], Error> {
		let remoteURL = SearchArticlesEndpoint.get(keyword: keyword, page: page).url()
		return httpClient
			.send(request: .init(url: remoteURL))
			.tryMap(ArticlesMapper.map)
			.eraseToAnyPublisher()
	}
}
