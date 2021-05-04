//
//  ArticlesPresenter.swift
//  PaginationNews
//

//

import Foundation

public final class ArticlesPresenter {
	private static let tableName = "Articles"
	public static var title: String {
		return NSLocalizedString("VIEW_TITLE",
		                         tableName: tableName,
		                         bundle: Bundle(for: Self.self),
		                         comment: "title of Articles View")
	}
}
