//
//  ArticlesViewController.swift
//  PaginationNews
//

//

import Combine
import UIKit
import PaginationNews

public protocol ArticlesPagingViewControllerDelegate {
    func didRequestPage()
}

public protocol ArticlesViewControllerDelegate {
    func didRequestRefresh()
}

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
    let pagingDelegate: ArticlesPagingViewControllerDelegate
    let refreshDelegate: ArticlesViewControllerDelegate

    public init?(coder: NSCoder,
          pagingDelegate: ArticlesPagingViewControllerDelegate,
          refreshDelegate: ArticlesViewControllerDelegate) {
        self.pagingDelegate = pagingDelegate
        self.refreshDelegate = refreshDelegate
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Articles"
        setupCollectionView()
        refresh()
    }

    public func append(_ cellControllers: [ArticleCellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ArticleCellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    public func set(_ cellControllers: [ArticleCellController]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
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
        refreshDelegate.didRequestRefresh()
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
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
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
        if let message = viewModel.message {
            showError(message)
        } else {
            hideError()
        }
    }

    private func showError(_ message: String) {
        view.addSubview(errorView)
        errorView.frame = view.bounds
        errorView.setMessage(message)
    }

    private func hideError() {
        errorView.setMessage(nil)
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
            pagingDelegate.didRequestPage()
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
