//
//  CellController.swift
//  PaginationNewsiOS
//
//  Created by Shinzan Takata on 2020/10/11.
//

import UIKit

public struct CellController: Hashable {
    public let id: AnyHashable
    public let dataSource: UICollectionViewDataSource
    public let delegate: UICollectionViewDelegate
    public let dataSourcePrefetching: UICollectionViewDataSourcePrefetching

    public init(id: AnyHashable, dataSource: UICollectionViewDataSource,
                delegate: UICollectionViewDelegate, dataSourcePrefetching: UICollectionViewDataSourcePrefetching) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = delegate
        self.dataSourcePrefetching = dataSourcePrefetching
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}
