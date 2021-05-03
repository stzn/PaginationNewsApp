//
//  CoreDataArticlesCacheStore.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/05/03.
//

import CoreData

public final class CoreDataArticlesCacheStore {
	private static let modelName = "ArticlesCacheStore"
	private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataArticlesCacheStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	enum StoreError: Error {
		case modelNotFound
		case failedToLoadPersistentContainer(Error)
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataArticlesCacheStore.model else {
			throw StoreError.modelNotFound
		}

		do {
			container = try NSPersistentContainer.load(name: CoreDataArticlesCacheStore.modelName, model: model, url: storeURL)
			context = container.newBackgroundContext()
		} catch {
			throw StoreError.failedToLoadPersistentContainer(error)
		}
	}
}

extension CoreDataArticlesCacheStore {
	public func retrieve() throws -> CachedArticles? {
		let context = self.context
		var cache: CachedArticles?
		context.performAndWait {}
		return cache
	}

	func save(_ articles: [Article], _ timestamp: Date) throws {}

	func delete() throws {}
}
