//
//  ArticlesViewController.swift
//  PaginationNewsiOS
//
//  Created by Shinzan Takata on 2021/01/03.
//

import UIKit

public final class ArticlesViewController: UIViewController {
	public let listViewController: ListViewController
	let categoryViewController: TopHeadlineCategoryViewController
	public init?(coder: NSCoder,
	             categoryController: TopHeadlineCategoryViewController,
	             listViewController: ListViewController) {
		self.categoryViewController = categoryController
		self.listViewController = listViewController
		self.listViewController.collectionView.showsVerticalScrollIndicator = false
		self.listViewController.collectionView.showsHorizontalScrollIndicator = false
		super.init(coder: coder)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		addCategoryViewControllerAsChild()
		addListViewControllerAsChild()
	}

	private func addCategoryViewControllerAsChild() {
		addChild(categoryViewController)
		view.addSubview(categoryViewController.view)
		categoryViewController.didMove(toParent: self)

		self.navigationItem.rightBarButtonItem = categoryViewController.button
	}

	private func addListViewControllerAsChild() {
		addChild(listViewController)
		view.addSubview(listViewController.view)
		listViewController.didMove(toParent: self)

		listViewController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			listViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			listViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			listViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
			listViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}
}
