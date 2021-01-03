//
//  SearchArticlesUIComposer.swift
//  PaginationNewsApp
//
//  Created by Shinzan Takata on 2021/01/02.
//

import Combine
import UIKit
import PaginationNews
import PaginationNewsiOS

final class SearchArticlesUIComposer {
    private init() {}

    static func articlesComposedWith(
        articlesLoader: @escaping (Int, String) -> AnyPublisher<([Article], Int), Error>,
        imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>,
        perPageCount: Int = APIConstants.articlesPerPageCount
    ) -> SearchArticlesViewController {
        let presentationAdapter = SearchArticlesPagingPresentationAdapter<ArticlesViewAdapter>(
            loader: articlesLoader,
            perPageCount: perPageCount
        )
        let bundle = Bundle(for: SearchArticlesViewController.self)
        let storyboard = UIStoryboard(name: String(describing: SearchArticlesViewController.self), bundle: bundle)
        let listViewController = ListViewController(onRefresh: { presentationAdapter.didRequestRefresh("") },
                                                    onPageRequest: presentationAdapter.didRequestPage)

        presentationAdapter.presenter = Presenter(
            contentView: ArticlesViewAdapter(controller: listViewController, imageLoader: imageLoader),
            loadingView: WeakReference(listViewController),
            errorView: WeakReference(listViewController),
            mapper: ArticlesPresenter.map)

        guard let controller = (storyboard.instantiateInitialViewController { coder in
            SearchArticlesViewController(
                coder: coder,
                listViewController: listViewController,
                didInput: presentationAdapter.didRequestRefresh
            )
        }) else {
            fatalError()
        }
        controller.title = ArticlesPresenter.searchTitle

        return controller
    }
}

