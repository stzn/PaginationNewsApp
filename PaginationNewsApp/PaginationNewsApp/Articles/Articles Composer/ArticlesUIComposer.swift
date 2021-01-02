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
    ) -> ListViewController {
        let presentationAdapter = ArticlesPagingPresentationAdapter<ArticlesViewAdapter>(loader: articlesLoader,
                                                                                         perPageCount: perPageCount)
        let viewController = makeListViewController(onRefresh: presentationAdapter.didRequestRefresh,
                                                        onPageRequest: presentationAdapter.didRequestPage,
                                                        title: ArticlesPresenter.title)
        presentationAdapter.presenter = Presenter(
            contentView: ArticlesViewAdapter(controller: viewController, imageLoader: imageLoader),
            loadingView: WeakReference(viewController),
            errorView: WeakReference(viewController),
            mapper: ArticlesPresenter.map)
        return viewController
    }

    private static func makeListViewController(
        onRefresh: @escaping () -> Void,
        onPageRequest: @escaping () -> Void,
        title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ArticlesViewController", bundle: bundle)
        guard let articlesController = (storyboard.instantiateInitialViewController { coder in
            ListViewController(coder: coder, onRefresh: onRefresh, onPageRequest: onPageRequest)
        }) else {
            fatalError()
        }
        articlesController.title = title
        return articlesController
    }
}

