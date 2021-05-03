//
//  ManagedCache+CoreDataClass.swift
//
//
//  Created by Shinzan Takata on 2021/05/03.
//
//

import Foundation
import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var article: NSOrderedSet
}
