//
//  SearchArticlesPresenter.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/01/03.
//

import Foundation

public final class SearchArticlesPresenter {
	public static func map(_ articles: [Article], keyword: String, pageNumber: Int) -> SearchArticlesViewModel {
		.init(articles: articles, keyword: keyword, pageNumber: pageNumber)
	}

	public static var title: String {
		return NSLocalizedString("VIEW_TITLE",
		                         tableName: tableName,
		                         bundle: Bundle(for: Self.self),
		                         comment: "title of Search Articles View")
	}

	public static var noKeywordMessage: String {
		return NSLocalizedString("NO_KEYWORD_MESSAGE",
		                         tableName: tableName,
		                         bundle: Bundle(for: Self.self),
		                         comment: "message for no keyword")
	}

	public static var noMatchedDataMessage: String {
		return NSLocalizedString("NO_MATCHED_DATA",
		                         tableName: tableName,
		                         bundle: Bundle(for: Self.self),
		                         comment: "message for no data")
	}

	private static let tableName = "SearchArticles"
}
