//
//  CacheArticlesUseCaseTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/02.
//

import XCTest
import PaginationNews

class CacheArticlesUseCaseTests: XCTestCase {
	func test_init_doesNotReceiveMessageUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_save_requestsCacheDeletion() throws {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let expected = [uniqueArticle]

		try sut.save(expected)

		XCTAssertEqual(store.receivedMessages, [.delete, .save(expected, timestamp)])
	}

	func test_save_doesNotRequestCacheInsertionOnDeletionError() throws {
		let (sut, store) = makeSUT()
		store.deleteError = anyNSError

		XCTAssertThrowsError(try sut.save([uniqueArticle]))

		XCTAssertEqual(store.receivedMessages, [.delete])
	}

	func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() throws {
		let timestamp = Date()
		let expected = [uniqueArticle]
		let (sut, store) = makeSUT(currentDate: { timestamp })

		try sut.save(expected)

		XCTAssertEqual(store.receivedMessages, [.delete, .save(expected, timestamp)])
	}

	// MARK: - Helpers

	private func makeSUT(
		currentDate: @escaping () -> Date = { Date() },
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: LocalArticlesManager, store: ArticlesCacheStoreSpy) {
		let store = ArticlesCacheStoreSpy()
		let sut = LocalArticlesManager(store: store, currentDate: currentDate)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(store, file: file, line: line)
		return (sut, store)
	}
}
