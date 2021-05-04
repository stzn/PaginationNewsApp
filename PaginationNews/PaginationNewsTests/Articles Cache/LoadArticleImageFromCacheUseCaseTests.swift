//
//  LoadArticleImageFromCacheUseCaseTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/04.
//

import XCTest
import PaginationNews

private enum ReceivedMessage: Equatable {
	case save(Data)
	case retrieve
}

private final class ArticleImageCacheStoreSpy: ArticleImageDataCacheStore {
	private(set) var receivedMessages: [ReceivedMessage] = []
	private(set) var expectedCachedData: Data?
	var retrieveError: Error?

	func retrieve() throws -> Data? {
		if let error = retrieveError {
			throw error
		}
		receivedMessages.append(.retrieve)
		return expectedCachedData
	}

	func save(_ data: Data) throws {
		receivedMessages.append(.save(data))
		expectedCachedData = data
	}
}

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
	}

	func test_load_deliversNoDataOnEmptyCache() throws {
		let (sut, store) = makeSUT()

		let received = try sut.load()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
		XCTAssertEqual(received, nil)
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
