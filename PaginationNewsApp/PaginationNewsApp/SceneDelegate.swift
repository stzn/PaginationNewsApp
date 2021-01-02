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
        let articlesViewController = ArticlesUIComposer.articlesComposedWith(
            articlesLoader: self.makeRemoteArticlesLoader(page:),
            imageLoader: self.makeRemoteImageLoader(url:))

        let navigationController = UINavigationController(
            rootViewController: articlesViewController)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
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
}
