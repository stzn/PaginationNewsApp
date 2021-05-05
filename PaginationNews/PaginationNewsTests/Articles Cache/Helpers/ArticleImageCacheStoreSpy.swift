//
//  ArticleImageCacheStoreSpy.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/04.
//

import Foundation
import PaginationNews

final class ArticleImageCacheStoreSpy: ArticleImageDataCacheStore {
	enum Message: Equatable {
		case save(String, Data)
		case retrieve(String)
	}

	private(set) var receivedMessages: [Message] = []
	private(set) var expectedCachedData: Data?
	var retrieveError: Error?
	var saveError: Error?

	func retrieve(for key: String) throws -> Data? {
		receivedMessages.append(.retrieve(key))
		if let error = retrieveError {
			throw error
		}
		return expectedCachedData
	}

	func save(for key: String, _ data: Data) throws {
		receivedMessages.append(.save(key, data))
		if let error = saveError {
			throw error
		}
		expectedCachedData = data
	}
}
