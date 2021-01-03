//
//  SearchArticlesEndpoint.swift
//  PaginationNews
//
//  Created by Shinzan Takata on 2021/01/02.
//

import Foundation

public enum SearchArticlesEndpoint {
    case get(keyword: String, page: Int,
             pageSize: Int = APIConstants.articlesPerPageCount)
    public func url(baseURL: URL = URL(string: APIConstants.baseURL)!) -> URL {
        switch self {
        case let .get(keyword, page, pageSize):
            let remoteURL = baseURL.appendingPathComponent("everything")
            var compoents = URLComponents(url: remoteURL, resolvingAgainstBaseURL: false)!
            compoents.queryItems = [
                URLQueryItem(name: "q", value: keyword),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "pageSize", value: String(pageSize)),
                URLQueryItem(name: "apiKey", value: APIConstants.apiKey),
            ]
            return compoents.url!
        }
    }
}
