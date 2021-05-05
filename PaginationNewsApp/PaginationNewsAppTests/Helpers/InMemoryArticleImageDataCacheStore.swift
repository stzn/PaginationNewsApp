//
//  InMemoryArticleImageDataCacheStore.swift
//  PaginationNewsAppTests
//
//  Created by Shinzan Takata on 2021/05/05.
//

import Foundation
import PaginationNews

final class InMemoryArticleImageDataCacheStore: ArticleImageDataCacheStore {
	var dictionary: [String: Data] = [:]
	func retrieve(for key: String) throws -> Data? { dictionary[key] }

	func save(for key: String, _ data: Data) throws {
		dictionary[key] = data
	}
}

extension InMemoryArticleImageDataCacheStore {
	static var empty: InMemoryArticleImageDataCacheStore { .init() }
}
