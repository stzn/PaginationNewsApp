//
//  LocalArticlesManager.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/05/02.
//

import Foundation

public final class LocalArticlesManager {
	enum Error: Swift.Error {
		case noCache
	}

	private let store: ArticlesCacheStore
	private let currentDate: () -> Date
	private let maxCacheDays: Int = 1

	public init(store: ArticlesCacheStore,
	            currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}

	public func load() throws -> [Article] {
		guard let cached = try store.retrieve() else {
			throw Error.noCache
		}
		guard cached.timestamp >= currentDate().adding(days: -maxCacheDays) else {
			return []
		}
		return cached.articles
	}

	public func save(_ articles: [Article]) throws {
		try store.delete()
		try store.save(articles)
	}
}
