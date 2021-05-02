//
//  LoadArticlesFromCacheUseCaseTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/02.
//

import XCTest
import PaginationNews

final class LocalArticlesManager {
	private let store: ArticlesCacheStoreSpy
	init(store: ArticlesCacheStoreSpy) {
		self.store = store
	}

	func load() throws -> [Article] {
		return store.retrieve()
	}
}

final class ArticlesCacheStoreSpy {
	enum Message {
		case retrieve
	}

	var receivedMessages: [Message] = []

	func retrieve() -> [Article] {
		receivedMessages.append(.retrieve)
		return []
	}
}

class LoadArticlesFromCacheUseCaseTests: XCTestCase {
	func test_init_doesNotReceiveMessageUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_load_requestsCacheRetrieval() throws {
		let (sut, store) = makeSUT()

		_ = try sut.load()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line
	) -> (sut: LocalArticlesManager, store: ArticlesCacheStoreSpy) {
		let store = ArticlesCacheStoreSpy()
		let sut = LocalArticlesManager(store: store)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(store, file: file, line: line)
		return (sut, store)
	}
}
