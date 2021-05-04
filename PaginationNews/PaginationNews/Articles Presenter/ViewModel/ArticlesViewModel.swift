//
//  ArticlesViewModel.swift
//  PaginationNews
//

//

import Foundation

public struct ArticlesViewModel {
	public let articles: [Article]
	public let pageNumber: Int

	public init(articles: [Article], pageNumber: Int) {
		self.articles = articles
		self.pageNumber = pageNumber
	}
}
