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

		_ = try sut.load()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_throwsErrorOnRetrievalError() throws {
		let (sut, store) = makeSUT()
		store.retrieveError = anyNSError

		XCTAssertThrowsError(try sut.load())
		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_deliversNoDataOnEmptyCache() throws {
		let (sut, store) = makeSUT()

		let received = try sut.load()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
		XCTAssertEqual(received, nil)
	}

	func test_load_deliversCachedData() throws {
		let (sut, store) = makeSUT()
		let expectedData = "expectedData".data(using: .utf8)!

		try sut.save(expectedData)
		let received = try sut.load()

		XCTAssertEqual(store.receivedMessages, [.save(expectedData), .retrieve])
		XCTAssertEqual(received, expectedData)
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
