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

	func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
		let context = self.context
		var result: Result<R, Error>!
		context.performAndWait { result = action(context) }
		return try result.get()
	}

	private func cleanUpReferencesToPersistentStores() {
		context.performAndWait {
			let coordinator = self.container.persistentStoreCoordinator
			try? coordinator.persistentStores.forEach(coordinator.remove)
		}
	}

	deinit {
		cleanUpReferencesToPersistentStores()
	}
}
