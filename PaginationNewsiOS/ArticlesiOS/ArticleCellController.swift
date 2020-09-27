//
//  ArticleCellController.swift
//  PaginationNews
//

//

import UIKit
import PaginationNews

public protocol ArticleCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class ArticleCellController: Hashable, ContentView {
    public typealias ViewModel = UIImage?

    private let viewModel: ArticleViewModel
    private let delegate: ArticleCellControllerDelegate
    private let errorImage: UIImage
    private var cell: ArticleCell?

    static func createLink(_ link: URL) -> NSAttributedString {
        NSMutableAttributedString(
            string: link.absoluteString,
            attributes: [NSAttributedString.Key.link: link])
    }

    public static func == (lhs: ArticleCellController, rhs: ArticleCellController) -> Bool {
        lhs.viewModel.id == rhs.viewModel.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(viewModel.id)
    }

    public init(viewModel: ArticleViewModel, errorImage: UIImage, delegate: ArticleCellControllerDelegate) {
        self.viewModel = viewModel
        self.errorImage = errorImage
        self.delegate = delegate
    }

    func view(_ cell: ArticleCell, at indexPath: IndexPath) {
        cell.titleLabel.text = viewModel.title
        cell.authorLabel.text = viewModel.displayAuthor
        cell.linkLabel.attributedText = viewModel.link
        cell.publishedAtLabel.text = viewModel.publishedAt
        cell.descriptionLabel.text = viewModel.description

        self.cell = cell
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }

    public func display(_ viewModel: ViewModel) {
        cell?.articleImageView.setImageAnimated(viewModel)
    }

    private func releaseCellForReuse() {
        cell?.resetUI()
        cell = nil
    }
}

extension ArticleCellController: LoadingView {
    public func display(_ viewModel: LoadingViewModel) {
        viewModel.isLoading ?
            cell?.loadingIndicator.startAnimating()
            : cell?.loadingIndicator.stopAnimating()
    }
}

extension ArticleCellController: ErrorView {
    public func display(_ viewModel: ErrorViewModel) {
        if viewModel.message != nil {
            cell?.articleImageView.setImageAnimated(errorImage)
        }
    }
}

private extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage

        guard newImage != nil else { return }

        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}

