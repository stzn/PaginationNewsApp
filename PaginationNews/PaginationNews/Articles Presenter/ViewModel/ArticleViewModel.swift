//
//  ArticleViewModel.swift
//  PaginationNews
//

//

import Foundation

public struct ArticleViewModel: Equatable {
	public let id: UUID
	let author: String
	public let title: String
	public let publishedAt: String
	public let link: NSAttributedString
	public let description: String

	public var displayAuthor: String {
		author.isEmpty ? "no author" : author
	}
}
