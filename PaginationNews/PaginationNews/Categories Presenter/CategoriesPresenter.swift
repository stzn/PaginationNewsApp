//
//  ArticlesPresenter.swift
//  PaginationNews
//

//

import Foundation

public final class CategoriesPresenter {
	public static func displayedCategoryName(_ category: TopHeadlineCategory) -> String {
		let key = category.rawValue.uppercased()
		return NSLocalizedString(key,
		                         tableName: "Categories",
		                         bundle: Bundle(for: Self.self),
		                         value: "not found",
		                         comment: "title of category")
	}
}
