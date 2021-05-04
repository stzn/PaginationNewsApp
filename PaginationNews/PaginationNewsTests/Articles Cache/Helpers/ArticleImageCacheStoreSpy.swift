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
		case save(Data)
		case retrieve
	}

	private(set) var receivedMessages: [Message] = []
	private(set) var expectedCachedData: Data?
	var retrieveError: Error?
	var saveError: Error?

	func retrieve() throws -> Data? {
		receivedMessages.append(.retrieve)
		if let error = retrieveError {
			throw error
		}
		return expectedCachedData
	}

	func save(_ data: Data) throws {
		receivedMessages.append(.save(data))
		if let error = saveError {
			throw error
		}
		expectedCachedData = data
	}
}
