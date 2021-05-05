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
		try store.retrieve(for: article.id.uuidString)
	}

	public func save(for article: Article, _ data: Data) throws {
		try store.save(for: article.id.uuidString, data)
	}
}
