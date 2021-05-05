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
		let (sut, store) = makeSUT()

		try sut.save([uniqueArticle])

		XCTAssertEqual(store.receivedMessages, [.delete, .save])
	}

	func test_save_doesNotRequestCacheInsertionOnDeletionError() throws {
		let (sut, store) = makeSUT()
		store.deleteError = anyNSError

		XCTAssertThrowsError(try sut.save([uniqueArticle]))

		XCTAssertEqual(store.receivedMessages, [.delete])
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
