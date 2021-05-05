//
//  InMemoryArticlesCacheStore.swift
//  PaginationNewsAppTests
//
//  Created by Shinzan Takata on 2021/05/05.
//

import Foundation
import PaginationNews

final class InMemoryArticlesCacheStore: ArticlesCacheStore {
	var cached: CachedArticles?
	func retrieve() throws -> CachedArticles? { cached }

	func save(_ articles: [Article], _ timestamp: Date) throws {
		cached = CachedArticles(articles, timestamp)
	}

	func delete() throws { cached = nil }
}

extension InMemoryArticlesCacheStore {
	static var empty: InMemoryArticlesCacheStore { .init() }
}
