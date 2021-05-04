//
//  LocalArticleImageDataManager.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/05/04.
//

import Foundation

public final class LocalArticleImageDataManager {
	private let store: ArticleImageDataCacheStore
	public init(store: ArticleImageDataCacheStore) {
		self.store = store
	}
}
