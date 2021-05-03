//
//  CoreDataArticlesCacheStore+ArticlesCacheStore.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/05/03.
//

import Foundation

extension CoreDataArticlesCacheStore: ArticlesCacheStore {
	public func retrieve() throws -> CachedArticles? {
		try performSync { context in
			Result {
				try ManagedCache.find(in: context).map {
					CachedArticles($0.articles, $0.timestamp)
				}
			}
		}
	}

	public func save(_ articles: [Article], _ timestamp: Date) throws {
		try performSync { context in
			Result {
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				managedCache.timestamp = timestamp
				managedCache.article = ManagedArticle.articles(from: articles, in: context)
				try context.save()
			}
		}
	}

	public func delete() throws {
		try performSync { context in
			Result {
				try ManagedCache.deleteCache(in: context)
			}
		}
	}
}
