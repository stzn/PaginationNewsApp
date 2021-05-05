//
//  Article.swift
//  PaginationNews
//

//

import Foundation

public struct Article: Hashable {
	let id: UUID
	let author: String?
	let title: String
	let description: String?
	let linkString: String?
	public let urlToImage: URL?
	let publishedAt: Date
	let sourceName: String

	public var imageKey: String? {
		urlToImage?.deletingPathExtension().lastPathComponent
	}
}
