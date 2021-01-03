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
        articlesLoader: @escaping (String, Int) -> AnyPublisher<([Article], Int), Error>,
        imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>,
        perPageCount: Int = APIConstants.articlesPerPageCount
    ) -> SearchArticlesViewController {
        let presentationAdapter = SearchArticlesPagingPresentationAdapter<SearchArticlesViewAdapter>(
            loader: articlesLoader,
            perPageCount: perPageCount
        )
        let bundle = Bundle(for: SearchArticlesViewController.self)
        let storyboard = UIStoryboard(name: String(describing: SearchArticlesViewController.self), bundle: bundle)
        let listViewController = ListViewController(onRefresh: { presentationAdapter.didRequestRefresh("") },
                                                    onPageRequest: presentationAdapter.didRequestPage)

        guard let controller = (storyboard.instantiateInitialViewController { coder in
            SearchArticlesViewController(
                coder: coder,
                listViewController: listViewController,
                didInput: presentationAdapter.didRequestRefresh
            )
        }) else {
            fatalError()
        }
        controller.title = SearchArticlesPresenter.title

        presentationAdapter.presenter = Presenter(
            contentView: SearchArticlesViewAdapter(controller: controller, imageLoader: imageLoader),
            loadingView: WeakReference(listViewController),
            errorView: WeakReference(listViewController),
            mapper: SearchArticlesPresenter.map)
        
        return controller
    }
}

