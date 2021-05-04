//
//  ArticlesPresenter.swift
//  PaginationNews
//

//

import Foundation

public final class CategoriesPresenter {
	public static var title: String {
		NSLocalizedString("TITLE",
		                  tableName: "Categories",
		                  bundle: Bundle(for: Self.self),
		                  value: "not found",
		                  comment: "title of Category View")
	}

	public static var cancel: String {
		NSLocalizedString("CANCEL",
		                  tableName: "Categories",
		                  bundle: Bundle(for: Self.self),
		                  value: "not found",
		                  comment: "title of cancel button")
	}

	public static func displayedCategoryName(_ category: TopHeadlineCategory) -> String {
		let key = category.rawValue.uppercased()
		return NSLocalizedString(key,
		                         tableName: "Categories",
		                         bundle: Bundle(for: Self.self),
		                         value: "not found",
		                         comment: "title of category")
	}
}
