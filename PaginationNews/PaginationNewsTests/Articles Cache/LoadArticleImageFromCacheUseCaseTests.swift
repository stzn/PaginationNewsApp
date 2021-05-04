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
	var receivedMessages: [ReceivedMessage] = []
	func retrieve() throws -> Data? {
		receivedMessages.append(.retrieve)
		return nil
	}

	func save(_ data: Data) throws {
		receivedMessages.append(.save(data))
	}
}

class LoadArticleImageFromCacheUseCaseTests: XCTestCase {
	func test_init_doesNotReceiveMessageUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
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
