//
//  SearchArticlesViewModel.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/01/03.
//

import Foundation

public struct SearchArticlesViewModel {
	public let articles: [Article]
	public let keyword: String
	public let pageNumber: Int

	public init(articles: [Article] = [],
	            keyword: String = "",
	            pageNumber: Int = 1) {
		self.articles = articles
		self.keyword = keyword
		self.pageNumber = pageNumber
	}
}
