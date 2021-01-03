//
//  SceneDelegate.swift
//  PaginationNews
//

//

import Combine
import UIKit
import PaginationNews

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
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
        let navigationController = UINavigationController(
            rootViewController: searchArticlesViewController)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    private var articlesViewController: UIViewController {
        ArticlesUIComposer.articlesComposedWith(
            articlesLoader: self.makeRemoteArticlesLoader(page:),
            imageLoader: self.makeRemoteImageLoader(url:))
    }

    private func makeRemoteArticlesLoader(page: Int) -> AnyPublisher<([Article], Int), Error> {
        let remoteURL = TopHeadlineEndpoint.get(page: page).url()
        return httpClient
            .send(request: .init(url: remoteURL))
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
        SearchArticlesUIComposer.articlesComposedWith(
            articlesLoader: self.makeRemoteSearchArticlesLoader(keyword:page:),
            imageLoader: self.makeRemoteImageLoader(url:))
    }

    private func makeRemoteSearchArticlesLoader(keyword: String, page: Int) -> AnyPublisher<([Article], Int), Error> {
        let remoteURL = SearchArticlesEndpoint.get(keyword: keyword, page: page).url()
        return httpClient
            .send(request: .init(url: remoteURL))
            .tryMap(ArticlesMapper.map)
            .eraseToAnyPublisher()
    }
}
