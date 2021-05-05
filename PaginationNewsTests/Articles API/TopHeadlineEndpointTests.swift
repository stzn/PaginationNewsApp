//
//  TopHeadlineEndpointTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/01/02.
//

import XCTest
import PaginationNews

class TopHeadlineEndpointTests: XCTestCase {
	func test_topheadline_endpointURLWithoutCategory() {
		let baseURL = URL(string: "https://base-url.com")!
		let received = TopHeadlineEndpoint.get(page: 1, pageSize: 20, country: .ad).url(baseURL: baseURL)
		XCTAssertEqual(received.scheme, "https", "scheme")
		XCTAssertEqual(received.host, "base-url.com", "host")
		XCTAssertEqual(received.path, "/top-headlines", "path")
		XCTAssertEqual(received.query?.contains("page=1"), true, "page query param")
		XCTAssertEqual(received.query?.contains("pageSize=20"), true, "page size query param")
		XCTAssertEqual(received.query?.contains("apiKey=\(APIConstants.apiKey)"), true, "apiKey query param")
		XCTAssertEqual(received.query?.contains("country=\(ISO3166_1Alpha_2.ad.rawValue)"), true, "country query param")
		XCTAssertEqual(received.query?.contains("category=\(TopHeadlineCategory.all.rawValue)"), false, "category query param")
	}

	func test_topheadline_endpointURLWithSelectedCategory() {
		let baseURL = URL(string: "https://base-url.com")!
		let received = TopHeadlineEndpoint.get(page: 1, pageSize: 20, country: .ad, category: .general).url(baseURL: baseURL)
		XCTAssertEqual(received.scheme, "https", "scheme")
		XCTAssertEqual(received.host, "base-url.com", "host")
		XCTAssertEqual(received.path, "/top-headlines", "path")
		XCTAssertEqual(received.query?.contains("page=1"), true, "page query param")
		XCTAssertEqual(received.query?.contains("pageSize=20"), true, "page size query param")
		XCTAssertEqual(received.query?.contains("apiKey=\(APIConstants.apiKey)"), true, "apiKey query param")
		XCTAssertEqual(received.query?.contains("country=\(ISO3166_1Alpha_2.ad.rawValue)"), true, "country query param")
		XCTAssertEqual(received.query?.contains("category=\(TopHeadlineCategory.general.rawValue)"), true, "category query param")
	}
}
