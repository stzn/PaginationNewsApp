//
//  TopHeadlineEndpoint.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/01/02.
//

import Foundation

public enum TopHeadlineEndpoint {
    case get(page: Int,
             pageSize: Int = APIConstants.articlesPerPageCount,
             country: ISO3166_1Alpha_2 = .jp,
             category: TopHeadlineCategory = .all)
    public func url(baseURL: URL = URL(string: APIConstants.baseURL)!) -> URL {
        switch self {
        case let .get(page, pageSize, country, category):
            let remoteURL = baseURL.appendingPathComponent("top-headlines")
            var compoents = URLComponents(url: remoteURL, resolvingAgainstBaseURL: false)!
            compoents.queryItems = [
                URLQueryItem(name: "country", value: country.rawValue),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "pageSize", value: String(pageSize)),
                URLQueryItem(name: "apiKey", value: APIConstants.apiKey),
            ]
            if category != .all {
                compoents.queryItems?.append(URLQueryItem(name: "category", value: category.rawValue))
            }
            return compoents.url!
        }
    }
}
