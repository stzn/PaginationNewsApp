//
//  ArticlesCacheStore.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/05/02.
//

public protocol ArticleImageDataCacheStore {
	func retrieve() throws -> Data?
	func save(_ data: Data) throws
}
