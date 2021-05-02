//
//  LoadArticlesFromCacheUseCaseTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/02.
//

import XCTest
import PaginationNews

final class LocalArticlesManager {
	private let store: ArticlesCacheStore
	init(store: ArticlesCacheStore) {
		self.store = store
	}

	func load() throws -> [Article] {
		return try store.retrieve()
	}
}

protocol ArticlesCacheStore {
	func retrieve() throws -> [Article]
}

final class ArticlesCacheStoreSpy: ArticlesCacheStore {
	enum Message {
		case retrieve
	}

	var receivedMessages: [Message] = []

	func retrieve() -> [Article] {
		receivedMessages.append(.retrieve)
		return []
	}
}

final class ArticlesCacheAlwaysFailStoreSpy: ArticlesCacheStore {
	func retrieve() throws -> [Article] {
		throw NSError(domain: "sample.shiz.ArticlesCacheStoreSpy", code: -1, userInfo: nil)
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

	func test_load_throwsErrorOnRetrievalError() throws {
		let sut = makeFailSUT()

		XCTAssertThrowsError(try sut.load())
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

	private func makeFailSUT(file: StaticString = #filePath, line: UInt = #line
	) -> LocalArticlesManager {
		let store = ArticlesCacheAlwaysFailStoreSpy()
		let sut = LocalArticlesManager(store: store)
		trackForMemoryLeaks(sut)
		trackForMemoryLeaks(store)
		return sut
	}
}
