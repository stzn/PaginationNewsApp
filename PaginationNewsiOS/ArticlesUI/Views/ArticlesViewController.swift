//
//  ArticlesViewController.swift
//  PaginationNewsiOS
//
//  Created by Shinzan Takata on 2021/01/03.
//

import UIKit

public final class ArticlesViewController: UIViewController {
    public let listViewController: ListViewController
    public init?(coder: NSCoder,
                 listViewController: ListViewController) {
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
            listViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            listViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    public func display(_ controllers: [CellController], keyword: String, pageNumber: Int) {
        switch (pageNumber, controllers.isEmpty, keyword.isEmpty) {
        case (1, true, true):
            listViewController.set(controllers)
        case (1, true, false):
            listViewController.set(controllers)
        case (1, false, _):
            listViewController.set(controllers)
        case (_, true, _), (_, false, _):
            listViewController.append(controllers)
        }
    }
}
