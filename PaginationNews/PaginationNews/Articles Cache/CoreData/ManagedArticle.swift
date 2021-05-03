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
	@NSManaged var id: UUID?
	@NSManaged var author: String?
	@NSManaged var title: String?
	@NSManaged var articleDescription: String?
	@NSManaged var linkString: String?
	@NSManaged var urlToImage: URL?
	@NSManaged var publishedAt: Date?
	@NSManaged var sourceName: String?
	@NSManaged var cache: ManagedCache?
}
