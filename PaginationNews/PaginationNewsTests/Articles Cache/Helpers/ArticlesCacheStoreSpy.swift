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
	}

	var receivedMessages: [Message] = []
	var expectedCachedArticles: CachedArticles?

	func retrieve() throws -> CachedArticles? {
		receivedMessages.append(.retrieve)
		return expectedCachedArticles
	}
}

final class ArticlesCacheAlwaysFailStoreSpy: ArticlesCacheStore {
	func retrieve() throws -> CachedArticles? {
		throw NSError(domain: "sample.shiz.ArticlesCacheStoreSpy", code: -1, userInfo: nil)
	}
}
