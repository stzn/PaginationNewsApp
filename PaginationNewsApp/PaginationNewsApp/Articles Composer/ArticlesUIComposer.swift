//
//  ArticlesUIComposer.swift
//  PaginationNews
//

//

import Combine
import UIKit
import PaginationNews
import PaginationNewsiOS

final class ArticlesUIComposer {
    private init() {}

    static func articlesComposedWith(
        articlesLoader: @escaping (Int) -> AnyPublisher<([Article], Int), Error>,
        imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>,
        perPageCount: Int = APIConstants.articlesPerPageCount
    ) -> ArticlesViewController {
        let presentationAdapter = ArticlesPagingPresentationAdapter<ArticlesViewAdapter>(loader: articlesLoader,
                                                                                         perPageCount: perPageCount)
        let viewController = makeArticlesViewController(pagingDelegate: presentationAdapter,
                                                        refreshDelegate: presentationAdapter,
                                                        title: ArticlesPresenter.title)
        presentationAdapter.presenter = Presenter(
            contentView: ArticlesViewAdapter(controller: viewController, imageLoader: imageLoader),
            loadingView: WeakReference(viewController),
            errorView: WeakReference(viewController),
            mapper: ArticlesPresenter.map)
        return viewController
    }

    private static func makeArticlesViewController(pagingDelegate: ArticlesPagingViewControllerDelegate,
                                                   refreshDelegate: ArticlesViewControllerDelegate,
                                                   title: String) -> ArticlesViewController {
        let bundle = Bundle(for: ArticlesViewController.self)
        let storyboard = UIStoryboard(name: "ArticlesViewController", bundle: bundle)
        guard let articlesController = (storyboard.instantiateInitialViewController { coder in
            ArticlesViewController(coder: coder,
                                   pagingDelegate: pagingDelegate,
                                   refreshDelegate: refreshDelegate)
        }) else {
            fatalError()
        }
        articlesController.title = title
        return articlesController
    }
}
