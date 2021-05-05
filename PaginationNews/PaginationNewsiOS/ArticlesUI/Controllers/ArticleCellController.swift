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

public final class ArticleCellController: NSObject {
	static let errorImage = UIImage(named: "noImage",
	                                in: Bundle(for: ArticleCellController.self),
	                                with: nil)!

	public typealias ViewModel = UIImage?

	private let viewModel: ArticleViewModel
	private let delegate: ArticleCellControllerDelegate
	private var cell: ArticleCell?

	static func createLink(_ link: URL) -> NSAttributedString {
		NSMutableAttributedString(
			string: link.absoluteString,
			attributes: [NSAttributedString.Key.link: link])
	}

	public static func == (lhs: ArticleCellController, rhs: ArticleCellController) -> Bool {
		lhs.viewModel.id == rhs.viewModel.id
	}

	public init(viewModel: ArticleViewModel, delegate: ArticleCellControllerDelegate) {
		self.viewModel = viewModel
		self.delegate = delegate
	}

	private func releaseCellForReuse() {
		cell = nil
	}

	private func cancel() {
		releaseCellForReuse()
		delegate.didCancelImageRequest()
	}
}

extension ArticleCellController: UICollectionViewDataSource {
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		1
	}

	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellRegistration = UICollectionView.CellRegistration<ArticleCell, ArticleCellController> { [weak self] (cell, indexPath, controller) in
			self?.view(cell, at: indexPath)
		}
		cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
		                                                    for: indexPath,
		                                                    item: self)
		return cell!
	}

	private func view(_ cell: ArticleCell, at indexPath: IndexPath) {
		cell.titleLabel.text = viewModel.title
		cell.authorLabel.text = viewModel.displayAuthor
		cell.linkLabel.attributedText = viewModel.link
		cell.publishedAtLabel.text = viewModel.publishedAt
		cell.descriptionLabel.text = viewModel.description
		cell.articleImageView.image = nil

		self.cell = cell
	}
}

extension ArticleCellController: UICollectionViewDelegate {
	public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		delegate.didRequestImage()
	}

	public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		cancel()
	}
}

extension ArticleCellController: UICollectionViewDataSourcePrefetching {
	public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		delegate.didRequestImage()
	}

	public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		cancel()
	}
}

extension ArticleCellController: ContentView {
	public func display(_ viewModel: ViewModel) {
		cell?.articleImageView.setImageAnimated(viewModel)
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
			cell?.articleImageView.setImageAnimated(Self.errorImage)
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
