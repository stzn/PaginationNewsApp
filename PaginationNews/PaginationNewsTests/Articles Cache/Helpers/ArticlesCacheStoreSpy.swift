//
//  ArticlesCacheStoreSpy.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/02.
//

import Foundation
import PaginationNews

final class ArticlesCacheStoreSpy: ArticlesCacheStore {
	enum Message {
		case retrieve
		case delete
	}

	var receivedMessages: [Message] = []
	var expectedCachedArticles: CachedArticles?

	func retrieve() throws -> CachedArticles? {
		receivedMessages.append(.retrieve)
		return expectedCachedArticles
	}

	func delete() throws {
		receivedMessages.append(.delete)
	}
}

final class ArticlesCacheAlwaysFailStoreSpy: ArticlesCacheStore {
	func retrieve() throws -> CachedArticles? {
		throw NSError(domain: "sample.shiz.ArticlesCacheAlwaysFailStoreSpy", code: -1, userInfo: nil)
	}

	func delete() throws {
		throw NSError(domain: "sample.shiz.ArticlesCacheAlwaysFailStoreSpy", code: -1, userInfo: nil)
	}
}
