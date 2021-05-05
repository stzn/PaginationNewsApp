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

	public func load(for article: Article) throws -> Data? {
		guard let key = article.imageKey else {
			return nil
		}
		return try store.retrieve(for: key)
	}

	public func save(for article: Article, _ data: Data) throws {
		guard let key = article.imageKey else {
			return
		}
		try store.save(for: key, data)
	}
}
