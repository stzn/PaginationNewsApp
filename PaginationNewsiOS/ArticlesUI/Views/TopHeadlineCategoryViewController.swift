//
//  TopHeadlineCategoryController.swift
//  PaginationNewsiOS
//
//  Created by Shinzan Takata on 2021/01/03.
//

import UIKit

public final class TopHeadlineCategoryViewController: UIViewController {
    private(set) lazy var button: UIBarButtonItem = {
        let image = UIImage(systemName: "line.horizontal.3")!.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
        return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showCategories))
    }()

    private let onSelect: (TopHeadlineCategory) -> Void

    public init(onSelect: @escaping (TopHeadlineCategory) -> Void) {
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func showCategories(_ sender: UIBarButtonItem) {
        let controller = UIAlertController(title: "Category", message: "", preferredStyle: .actionSheet)
        for category in TopHeadlineCategory.allCases {
            let option = UIAlertAction(title: category.rawValue, style: .default) { [weak self] _ in
                self?.onSelect(category)
            }
            controller.addAction(option)
        }
        present(controller, animated: true)
    }
}
