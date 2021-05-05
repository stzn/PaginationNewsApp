//
//  SearchArticlesViewController.swift
//  PaginationNewsiOS
//
//  Created by Shinzan Takata on 2020/10/11.
//

import UIKit
import PaginationNews

private enum EmptyReason {
	case noKeyword
	case noData

	var message: String {
		switch self {
		case .noKeyword: return SearchArticlesPresenter.noKeywordMessage
		case .noData: return SearchArticlesPresenter.noMatchedDataMessage
		}
	}
}

public final class SearchArticlesViewController: UIViewController {
	@IBOutlet public private(set) weak var searchBar: UISearchBar!
	private(set) lazy var emptyView = EmptyUIView()
	public let listViewController: ListViewController
	public let didInput: (String) -> Void
	public init?(coder: NSCoder,
	             listViewController: ListViewController,
	             didInput: @escaping (String) -> Void) {
		self.listViewController = listViewController
		self.listViewController.collectionView.showsVerticalScrollIndicator = false
		self.listViewController.collectionView.showsHorizontalScrollIndicator = false
		self.didInput = didInput
		super.init(coder: coder)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		searchBar.delegate = self
		addListViewControllerAsChild()
	}

	private func addListViewControllerAsChild() {
		addChild(listViewController)
		view.addSubview(listViewController.view)
		listViewController.didMove(toParent: self)

		listViewController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			listViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			listViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			listViewController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
			listViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}

	public func display(_ controllers: [CellController], keyword: String, pageNumber: Int) {
		switch (pageNumber, controllers.isEmpty, keyword.isEmpty) {
		case (1, true, true):
			showEmpty(reason: .noKeyword, on: self)
			listViewController.set(controllers)
		case (1, true, false):
			showEmpty(reason: .noData, on: self)
			listViewController.set(controllers)
		case (1, false, _):
			hideEmpty()
			listViewController.set(controllers)
		case (_, true, _), (_, false, _):
			hideEmpty()
			listViewController.append(controllers)
		}
	}

	private func showEmpty(reason: EmptyReason, on viewController: SearchArticlesViewController) {
		viewController.view.addSubview(emptyView)
		emptyView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			emptyView.topAnchor.constraint(equalTo: viewController.searchBar.bottomAnchor),
			emptyView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
			emptyView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
			emptyView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
		])
		emptyView.setMessage(reason.message)
	}

	private func hideEmpty() {
		emptyView.setMessage(nil)
		emptyView.removeFromSuperview()
	}
}

extension SearchArticlesViewController: UISearchBarDelegate {
	public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		didInput(searchText)
	}
}
