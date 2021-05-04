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

	public func load() throws -> Data? {
		try store.retrieve()
	}

	public func save(_ data: Data) throws {
		try store.save(data)
	}
}
