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
		case save
	}

	var receivedMessages: [Message] = []
	var expectedCachedArticles: CachedArticles?

	var retrieveError: Error?
	var deleteError: Error?
	var saveError: Error?

	func retrieve() throws -> CachedArticles? {
		receivedMessages.append(.retrieve)
		if let error = retrieveError {
			throw error
		}
		return expectedCachedArticles
	}

	func delete() throws {
		receivedMessages.append(.delete)
		if let error = deleteError {
			throw error
		}
	}

	func save(_ articles: [Article]) throws {
		receivedMessages.append(.save)
		if let error = saveError {
			throw error
		}
	}
}
