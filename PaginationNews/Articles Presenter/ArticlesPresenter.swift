//
//  ArticlesPresenter.swift
//  PaginationNews
//

//

import Foundation

public final class ArticlesPresenter {
    public static func map(_ articles: [Article], pageNumber: Int) -> ArticlesViewModel {
        .init(articles: articles, pageNumber: pageNumber)
    }

    private static let tableName = "Articles"
    public static var title: String {
        return NSLocalizedString("VIEW_TITLE",
                                 tableName: tableName,
                                 bundle: Bundle(for: Self.self),
                                 comment: "title of Articles View")
    }

    public static var searchTitle: String {
        return NSLocalizedString("SEARCH_VIEW_TITLE",
                                 tableName: tableName,
                                 bundle: Bundle(for: Self.self),
                                 comment: "title of Search Articles View")
    }

}
