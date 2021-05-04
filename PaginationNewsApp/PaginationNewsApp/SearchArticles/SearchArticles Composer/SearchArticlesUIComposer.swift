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
		articlesLoader: @escaping (String, Int) -> AnyPublisher<[Article], Error>,
		imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>,
		perPageCount: Int = APIConstants.articlesPerPageCount
	) -> SearchArticlesViewController {
		var keyword: String = ""
		let presentationAdapter = SearchArticlesPagingPresentationAdapter<SearchArticlesViewAdapter>(
			loader: articlesLoader,
			perPageCount: perPageCount
		)
		let bundle = Bundle(for: SearchArticlesViewController.self)
		let storyboard = UIStoryboard(name: String(describing: SearchArticlesViewController.self), bundle: bundle)
		let listViewController = ListViewController(onRefresh: { presentationAdapter.didRequestRefresh(keyword) },
		                                            onPageRequest: presentationAdapter.didRequestPage)

		guard let controller = (storyboard.instantiateInitialViewController { coder in
			SearchArticlesViewController(
				coder: coder,
				listViewController: listViewController,
				didInput: { input in
					keyword = input
					presentationAdapter.didRequestRefresh(input)
				}
			)
		}) else {
			fatalError()
		}
		controller.title = SearchArticlesPresenter.title

		presentationAdapter.presenter = Presenter(
			contentView: SearchArticlesViewAdapter(controller: controller, imageLoader: imageLoader),
			loadingView: WeakReference(listViewController),
			errorView: WeakReference(listViewController),
			mapper: { $0 })

		return controller
	}
}
