//
//  FileArticleImageDataCacheStore.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/05/04.
//

import Foundation

public final class FileArticleImageDataCacheStore: ArticleImageDataCacheStore {
	private let baseDirectroy: URL
	public init(baseDirectroy: URL) {
		self.baseDirectroy = baseDirectroy
	}

	public func retrieve(for key: String) throws -> Data? {
		nil
	}

	public func save(for key: String, _ data: Data) throws {}
}
