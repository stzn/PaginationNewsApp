//
//  NullStore.swift
//  PaginationNewsApp
//
//  Created by Shinzan Takata on 2021/05/05.
//

import Foundation
import PaginationNews

final class NullStore: ArticlesCacheStore {
	// MARK: - ArticlesCacheStore
	func retrieve() throws -> CachedArticles? { nil }
	func save(_ articles: [Article], _ timestamp: Date) throws {}
	func delete() throws {}
}
