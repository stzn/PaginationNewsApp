//
//  ArticlesViewController.swift
//  PaginationNews
//

//

import Combine
import UIKit
import PaginationNews

public final class ArticlesViewController: UIViewController {
    typealias Section = Int
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ArticleCellController>

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

    required init?(coder: NSCoder) {
        fatalError()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupBindings()
        refresh()
    }

    public func set(_ cellControllers: [ArticleCellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ArticleCellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    public func append(_ cellControllers: [ArticleCellController]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ArticlesViewController {
    func setupBindings() {
        errorView.retryPublisher.sink { [weak self] in
            self?.hideError()
            self?.onRefresh()
        }.store(in: &cancellables)
    }
}

extension ArticlesViewController {
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
        let cellRegistration = UICollectionView.CellRegistration<ArticleCell, ArticleCellController> { (cell, indexPath, controller) in
            controller.view(cell, at: indexPath)
        }

        dataSource = .init(collectionView: collectionView) { (collectionView, indexPath, controller) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: controller)
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

extension ArticlesViewController: LoadingView, ErrorView {
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

extension ArticlesViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath)?.preload()
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath)?.cancelLoad()
    }

    func cellController(forItemAt indexPath: IndexPath) -> ArticleCellController? {
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

extension ArticlesViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            cellController(forItemAt: $0)?.preload()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            cellController(forItemAt: $0)?.cancelLoad()
        }
    }
}
