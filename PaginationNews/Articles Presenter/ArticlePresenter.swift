//
//  ArticlePresenter.swift
//  PaginationNews
//

//

import UIKit

public final class ArticlePresenter {
    public static func map(_ article: Article) -> ArticleViewModel {
        ArticleViewModel(id: article.id,
              author: article.author ?? "",
              title: article.title,
              publishedAt: PublishedAtDateFormatter.format(from: article.publishedAt),
              link: createLink(article.linkString),
              description: article.description ?? "")
    }

    private static func createLink(_ link: String?) -> NSAttributedString {
        guard let link = link else {
            return NSAttributedString()
        }
        return NSMutableAttributedString(
            string: link,
            attributes: [.link: link])
    }
}

final class PublishedAtDateFormatter {
    static var formatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        return formatter
    }()

    static func format(from date: Date, relativeTo standard: Date = Date()) -> String {
        formatter.localizedString(for: date, relativeTo: standard)
    }
}
