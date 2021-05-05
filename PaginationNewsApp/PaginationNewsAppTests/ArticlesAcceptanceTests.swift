//
//  ArticlesAcceptanceTests.swift
//  PaginationNewsAppTests
//
//  Created by Shinzan Takata on 2021/05/05.
//

import XCTest
import PaginationNews
import PaginationNewsiOS
@testable import PaginationNewsApp

class ArticlesAcceptanceTests: XCTestCase {
	func test_onLaunch_displaysRemoteArticlesWhenCustomerHasConnectivity() {
		let article = launch(httpClient: .online(response))

		article.loadViewIfNeeded()
		XCTAssertEqual(article.numberOfRenderedArticleViews(), 2)
		XCTAssertEqual(article.renderedArticleImageData(at: 0), makeImageData0())
		XCTAssertEqual(article.renderedArticleImageData(at: 1), makeImageData1())

		article.simulateUserScrollToBottom()
		XCTAssertEqual(article.numberOfRenderedArticleViews(), 3)
		XCTAssertEqual(article.renderedArticleImageData(at: 0), makeImageData0())
		XCTAssertEqual(article.renderedArticleImageData(at: 1), makeImageData1())
		XCTAssertEqual(article.renderedArticleImageData(at: 2), makeImageData2())

		article.simulateUserScrollToBottom()
		XCTAssertEqual(article.numberOfRenderedArticleViews(), 3)
		XCTAssertEqual(article.renderedArticleImageData(at: 0), makeImageData0())
		XCTAssertEqual(article.renderedArticleImageData(at: 1), makeImageData1())
		XCTAssertEqual(article.renderedArticleImageData(at: 2), makeImageData2())
	}

	// MARK: - Helpers
	private func launch(
		httpClient: HTTPClientStub = .offline,
		articlesCacheStore: InMemoryArticlesCacheStore = .empty,
		imageDataStore: InMemoryArticleImageDataCacheStore = .empty,
		scheduler: AnyDispatchQueueScheduler = .immediateOnMainQueue
	) -> ArticlesViewController {
		let sut = SceneDelegate(httpClient: httpClient,
		                        articlesCacheStore: articlesCacheStore,
		                        imageDataStore: imageDataStore,
		                        scheduler: scheduler)
		sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		sut.configureWindow()

		let tab = sut.window?.rootViewController as? UITabBarController
		let nav = tab?.viewControllers?.first as? UINavigationController
		return nav?.topViewController as! ArticlesViewController
	}

	private func response(_ request: URLRequest) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: request.url!), response)
	}

	private func makeImageData0() -> Data { UIImage.make(withColor: .red).pngData()! }
	private func makeImageData1() -> Data { UIImage.make(withColor: .green).pngData()! }
	private func makeImageData2() -> Data { UIImage.make(withColor: .blue).pngData()! }

	private func makeData(for url: URL) -> Data {
		switch url.path {
		case "/image-0": return makeImageData0()
		case "/image-1": return makeImageData1()
		case "/image-2": return makeImageData2()
		case "/v2/top-headlines" where url.query?.contains("page=1") == true:
			return makeFirstPageArticlesData()
		case "/v2/top-headlines" where url.query?.contains("page=2") == true:
			return makeSecondPageArticlesData()
		default: return Data()
		}
	}

	private func makeFirstPageArticlesData() -> Data {
		return try! JSONSerialization.data(
			withJSONObject: [
				"status": "ok",
				"totalResults": 3,
				"articles": [
					[
						"source": ["id": "bbc-news", "name": "BBC News"],
						"author": "BBC News",
						"title": "Indonesian firm busted for reusing Covid nasal swab tests",
						"description": "Up to 9,000 passengers at a local airport may have been tested with washed and reused swab sticks.",
						"url": "http://www.bbc.co.uk/news/world-asia-56990253",
						"urlToImage": "https://ichef.bbci.co.uk/image-0",
						"publishedAt": "2021-05-20T00:39:57Z",
						"content": "image captionCovid nasal swab testing has become routine in many countries hit by the global pandemic (file picture)\r\nSeveral employees of a pharmaceutical company have been arrested in Indonesia for… [+2416 chars]"
					],
					[
						"source": ["id": "techcrunch", "name": "techcrunch"],
						"author": "Rebecca Bellan",
						"title": "Tesla sees bitcoin as important financial tool to access cash quickly",
						"description": "Tesla’s relationship with bitcoin is not a dalliance, according to the comments made by the company’s CFO and dubbed “master of coin” Zach Kirkhorn during an earnings call Monday. Instead, the company believes in the longevity of bitcoin, despite its volatili…",
						"url": "http://techcrunch.com/2021/04/26/tesla-sees-bitcoin-as-important-financial-tool-to-access-cash-quickly/",
						"urlToImage": "https://techcrunch.com/image-1",
						"publishedAt": "2020-12-20T11:39:03Z",
						"content": "Tesla’s relationship with bitcoin is not a dalliance, according to the comments made by the company’s CFO and dubbed “master of coin” Zach Kirkhorn during an earnings call Monday. Instead, the compan… [+3073 chars]"
					],
				]
			]
		)
	}

	private func makeSecondPageArticlesData() -> Data {
		return try! JSONSerialization.data(
			withJSONObject: [
				"status": "ok",
				"totalResults": 3,
				"articles": [
					[
						"source": ["id": "bbc-news", "name": "BBC News"],
						"author": "BBC News",
						"title": "Indonesian firm busted for reusing Covid nasal swab tests",
						"description": "Up to 9,000 passengers at a local airport may have been tested with washed and reused swab sticks.",
						"url": "http://www.bbc.co.uk/news/world-asia-56990253",
						"urlToImage": "https://ichef.bbci.co.uk/image-2",
						"publishedAt": "2021-05-20T00:39:57Z",
						"content": "image captionCovid nasal swab testing has become routine in many countries hit by the global pandemic (file picture)\r\nSeveral employees of a pharmaceutical company have been arrested in Indonesia for… [+2416 chars]"
					],
				]
			]
		)
	}
}
