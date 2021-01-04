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

        let listViewController = ListViewController(onRefresh: presentationAdapter.didRequestRefresh,
                                                    onPageRequest: presentationAdapter.didRequestPage)
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ArticlesViewController", bundle: bundle)
        guard let articlesController = (storyboard.instantiateInitialViewController { coder in
            ArticlesViewController(coder: coder,
                                   categoryController: TopHeadlineCategoryViewController(onSelect: { _ in }),
                                   listViewController: listViewController)
        }) else {
            fatalError()
        }
        articlesController.title = ArticlesPresenter.title

        presentationAdapter.presenter = Presenter(
            contentView: ArticlesViewAdapter(controller: listViewController, imageLoader: imageLoader),
            loadingView: WeakReference(listViewController),
            errorView: WeakReference(listViewController),
            mapper: ArticlesPresenter.map
        )
        return articlesController
    }
}

