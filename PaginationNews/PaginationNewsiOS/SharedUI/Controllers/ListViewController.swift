//
//  ListViewController.swift
//  PaginationNewsiOS
//
//  Created by Shinzan Takata on 2020/10/11.
//

import Combine
import UIKit
import PaginationNews

public final class ListViewController: UIViewController {
	typealias Section = Int
	typealias DataSource = UICollectionViewDiffableDataSource<Section, CellController>

	let collectionView: UICollectionView = {
		UICollectionView(frame: .zero,
		                 collectionViewLayout: UICollectionViewFlowLayout())
	}()

	private(set) var dataSource: DataSource!
	private let appearance = UICollectionLayoutListConfiguration.Appearance.plain
	private var cancellables = Set<AnyCancellable>()

	private(set) lazy var errorView = ErrorUIView()
	let refreshControl = UIRefreshControl()

	private let onRefresh: () -> Void
	private let onPageRequest: () -> Void

	public init?(coder: NSCoder,
	             onRefresh: @escaping () -> Void,
	             onPageRequest: @escaping () -> Void) {
		self.onRefresh = onRefresh
		self.onPageRequest = onPageRequest
		super.init(coder: coder)
	}

	public init(onRefresh: @escaping () -> Void,
	            onPageRequest: @escaping () -> Void) {
		self.onRefresh = onRefresh
		self.onPageRequest = onPageRequest
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		setupCollectionView()
		setupBindings()
		refresh()
	}

	public func set(_ cellControllers: [CellController]) {
		var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
		snapshot.appendSections([0])
		snapshot.appendItems(cellControllers)
		dataSource.apply(snapshot, animatingDifferences: false)
	}
}

extension ListViewController {
	func setupBindings() {
		errorView.retryPublisher.sink { [weak self] in
			self?.hideError()
			self?.onRefresh()
		}.store(in: &cancellables)
	}
}

extension ListViewController {
	private func setupCollectionView() {
		collectionView.backgroundColor = .systemBackground
		setupLayout()
		setupDataSoruce()
		collectionView.dataSource = dataSource
		collectionView.delegate = self
		collectionView.prefetchDataSource = self
		collectionView.refreshControl = refreshControl
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
	}

	@objc private func refresh() {
		onRefresh()
	}

	private func setupDataSoruce() {
		dataSource = .init(collectionView: collectionView) { (collectionView, indexPath, controller) in
			controller.dataSource.collectionView(collectionView, cellForItemAt: indexPath)
		}
	}

	private func setupLayout() {
		view.addSubview(collectionView)
		collectionView.collectionViewLayout = createLayout()
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}

	private func createLayout() -> UICollectionViewCompositionalLayout {
		let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
		let item = NSCollectionLayoutItem(layoutSize: size)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)
		section.interGroupSpacing = 10
		return UICollectionViewCompositionalLayout(section: section)
	}
}

extension ListViewController: LoadingView, ErrorView {
	public func display(_ viewModel: LoadingViewModel) {
		viewModel.isLoading ?
			collectionView.refreshControl?.beginRefreshing()
			: collectionView.refreshControl?.endRefreshing()
	}

	public func display(_ viewModel: ErrorViewModel) {
		if let message = viewModel.message,
		   let retryButtonTitle = viewModel.retryButtonTitle {
			showError(message, retryButtonTitle: retryButtonTitle)
		} else {
			hideError()
		}
	}

	private func showError(_ message: String, retryButtonTitle: String) {
		view.addSubview(errorView)
		errorView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			errorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			errorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			errorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
		])
		errorView.setMessage(message, retryButtonTitle: retryButtonTitle)
	}

	private func hideError() {
		errorView.setMessage(nil, retryButtonTitle: nil)
		errorView.removeFromSuperview()
	}
}

extension ListViewController: UICollectionViewDelegate {
	public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		cellController(forItemAt: indexPath)?.delegate.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
	}

	public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		cellController(forItemAt: indexPath)?.delegate.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
	}

	func cellController(forItemAt indexPath: IndexPath) -> CellController? {
		let controller = dataSource.itemIdentifier(for: indexPath)
		return controller
	}

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView.isDragging else {
			return
		}

		let offsetY = scrollView.contentOffset.y
		let contentHeight = scrollView.contentSize.height
		if offsetY > contentHeight - scrollView.frame.height {
			onPageRequest()
		}
	}
}

extension ListViewController: UICollectionViewDataSourcePrefetching {
	public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		indexPaths.forEach {
			cellController(forItemAt: $0)?.dataSourcePrefetching.collectionView(collectionView, prefetchItemsAt: [$0])
		}
	}

	public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		indexPaths.forEach {
			cellController(forItemAt: $0)?.dataSourcePrefetching.collectionView?(collectionView, cancelPrefetchingForItemsAt: [$0])
		}
	}
}
