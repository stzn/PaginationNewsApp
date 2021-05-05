//
//  ArticleImageDataCacheStore.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/05/02.
//

public protocol ArticleImageDataCacheStore {
	func retrieve(for key: String) throws -> Data?
	func save(for key: String, _ data: Data) throws
}
