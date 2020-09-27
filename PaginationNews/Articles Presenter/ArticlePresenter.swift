//
//  ArticlePresenter.swift
//  PaginationNews
//

//

import UIKit

public final class ArticlePresenter {
    public static func map(_ article: Article,
                           calendar: Calendar = .current,
                           locale: Locale = .current) -> ArticleViewModel {
        ArticleViewModel(id: article.id,
              author: article.author ?? "",
              title: article.title,
              publishedAt: createFormattedPulishedAtString(article.publishedAt,
                                                           calendar: calendar, locale: locale),
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

    private static func createFormattedPulishedAtString(
        _ publishedAt: Date, calendar: Calendar, locale: Locale) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }
}
