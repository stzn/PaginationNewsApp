//
//  ArticlesCacheStore.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/05/02.
//

public typealias CachedArticles = (articles: [Article], timestamp: Date)

public protocol ArticlesCacheStore {
	func retrieve() throws -> CachedArticles?
	func save(_ articles: [Article]) throws
	func delete() throws
}
