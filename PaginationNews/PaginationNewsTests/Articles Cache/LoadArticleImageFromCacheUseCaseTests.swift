//
//  LoadArticleImageFromCacheUseCaseTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/04.
//

import XCTest
import PaginationNews

class LoadArticleImageFromCacheUseCaseTests: XCTestCase {
	func test_init_doesNotReceiveMessageUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_load_requestsCacheRetrieval() throws {
		let (sut, store) = makeSUT()
		let article = uniqueArticle

		_ = try sut.load(for: article)

		XCTAssertEqual(store.receivedMessages, [.retrieve(article.imageKey!)])
	}

	func test_load_throwsErrorOnRetrievalError() throws {
		let (sut, store) = makeSUT()
		let article = uniqueArticle
		store.retrieveError = anyNSError

		XCTAssertThrowsError(try sut.load(for: article))
		XCTAssertEqual(store.receivedMessages, [.retrieve(article.imageKey!)])
	}

	func test_load_deliversNoDataOnEmptyCache() throws {
		let (sut, store) = makeSUT()
		let article = uniqueArticle

		let received = try sut.load(for: article)

		XCTAssertEqual(store.receivedMessages, [.retrieve(article.imageKey!)])
		XCTAssertEqual(received, nil)
	}

	func test_load_deliversCachedData() throws {
		let (sut, store) = makeSUT()
		let expectedData = "expectedData".data(using: .utf8)!
		let article = uniqueArticle
		let articleKey = article.imageKey!

		try sut.save(for: article, expectedData)
		let received = try sut.load(for: article)

		XCTAssertEqual(store.receivedMessages, [.save(articleKey, expectedData), .retrieve(articleKey)])
		XCTAssertEqual(received, expectedData)
	}

	func test_save_failsOnInsertionError() throws {
		let (sut, store) = makeSUT()
		let expected = "expectedData".data(using: .utf8)!
		let article = uniqueArticle
		store.saveError = anyNSError

		XCTAssertThrowsError(try sut.save(for: article, expected))
		XCTAssertEqual(store.receivedMessages, [.save(article.imageKey!, expected)])
	}

	// MARK: - Helpers

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: LocalArticleImageDataManager, store: ArticleImageCacheStoreSpy) {
		let store = ArticleImageCacheStoreSpy()
		let sut = LocalArticleImageDataManager(store: store)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(store, file: file, line: line)
		return (sut, store)
	}
}
