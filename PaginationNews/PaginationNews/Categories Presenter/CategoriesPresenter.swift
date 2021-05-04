//
//  ArticlesPresenter.swift
//  PaginationNews
//

//

import Foundation

public final class CategoriesPresenter {
	public static func displayedCategoryName(_ category: TopHeadlineCategory) -> String {
		func localized(of key: String) -> String {
			NSLocalizedString(key,
			                  tableName: "Categories",
			                  bundle: Bundle(for: Self.self),
			                  comment: "title of \(key)")
		}
		switch category {
		case .all:
			return localized(of: "ALL")
		case .business:
			return localized(of: "BUSINESS")
		case .entertainment:
			return localized(of: "ENTERTAINMENT")
		case .general:
			return localized(of: "GENERAL")
		case .health:
			return localized(of: "HEALTH")
		case .science:
			return localized(of: "SCIENCE")
		case .sports:
			return localized(of: "SPORTS")
		case .technology:
			return localized(of: "TECHNOLOGY")
		}
	}
}
