//
//  SharedTestHelpers.swift
//  PaginationNewsTests
//

//

import Foundation
@testable import PaginationNews

var anyNSError: NSError {
    NSError(domain: "any error", code: 0)
}

var anyURL: URL {
    URL(string: "http://any-url.com")!
}

var uniqueArticle: Article {
    Article(id: UUID(),
            author: "any author", title: "any title", description: "any description",
            linkString: anyURL.absoluteString,
            urlToImage: anyURL,
            publishedAt: Date(timeIntervalSince1970: 0),
            sourceName: "any source name")
}

struct AnyView: ContentView {
    func display(_ viewModel: Never) {}
    typealias ViewModel = Never
}

extension Date {
    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}
