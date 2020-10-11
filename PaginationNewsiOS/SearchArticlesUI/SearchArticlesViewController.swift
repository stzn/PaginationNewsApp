//
//  SearchArticlesViewController.swift
//  PaginationNewsiOS
//
//  Created by Shinzan Takata on 2020/10/11.
//

import UIKit

public final class SearchArticlesViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    public let listViewController: ListViewController
    public let didInput: (String) -> Void
    public init?(coder: NSCoder,
                 listViewController: ListViewController,
                 didInput: @escaping (String) -> Void) {
        self.listViewController = listViewController
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
}

extension SearchArticlesViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        didInput(searchBar.text ?? "")
    }
}
