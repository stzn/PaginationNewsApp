//
//  ManagedArticle+CoreDataClass.swift
//
//
//  Created by Shinzan Takata on 2021/05/03.
//
//

import Foundation
import CoreData

@objc(ManagedArticle)
class ManagedArticle: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var author: String?
	@NSManaged var title: String
	@NSManaged var articleDescription: String?
	@NSManaged var linkString: String?
	@NSManaged var urlToImage: URL?
	@NSManaged var publishedAt: Date
	@NSManaged var sourceName: String
	@NSManaged var cache: ManagedCache?
}

extension ManagedArticle {
	static func articles(from articles: [Article], in context: NSManagedObjectContext) -> NSOrderedSet {
		let articles = NSOrderedSet(array: articles.map { article in
			let managed = ManagedArticle(context: context)
			managed.id = article.id
			managed.author = article.author
			managed.title = article.title
			managed.articleDescription = article.description
			managed.linkString = article.linkString
			managed.urlToImage = article.urlToImage
			managed.publishedAt = article.publishedAt
			managed.sourceName = article.sourceName
			return managed
		})
		return articles
	}

	var article: Article {
		Article(
			id: id, author: author,
			title: title,
			description: articleDescription,
			linkString: linkString,
			urlToImage: urlToImage,
			publishedAt: publishedAt,
			sourceName: sourceName
		)
	}
}
