//
//  LoadArticlesFromCacheUseCaseTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/02.
//

import XCTest
import PaginationNews

final class LocalArticlesManager {
	enum Error: Swift.Error {
		case noCache
	}

	private let store: ArticlesCacheStore
	private let currentDate: () -> Date
	private let maxCacheDays: Int = 1

	init(store: ArticlesCacheStore,
	     currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}

	func load() throws -> [Article] {
		guard let cached = try store.retrieve() else {
			throw Error.noCache
		}
		guard cached.timestamp.adding(days: -maxCacheDays) < currentDate() else {
			return []
		}
		return cached.articles
	}
}

typealias CachedArticles = (articles: [Article], timestamp: Date)

protocol ArticlesCacheStore {
	func retrieve() throws -> CachedArticles?
}

final class ArticlesCacheStoreSpy: ArticlesCacheStore {
	enum Message {
		case retrieve
	}

	var receivedMessages: [Message] = []
	var expectedCachedArticles: CachedArticles?

	func retrieve() throws -> CachedArticles? {
		receivedMessages.append(.retrieve)
		return expectedCachedArticles
	}
}

final class ArticlesCacheAlwaysFailStoreSpy: ArticlesCacheStore {
	func retrieve() throws -> CachedArticles? {
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

		XCTAssertThrowsError(try sut.load())

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_throwsErrorOnRetrievalError() throws {
		let sut = makeFailSUT()

		XCTAssertThrowsError(try sut.load())
	}

	func test_load_deliversNoArticlesOnEmptyCache() throws {
		let (sut, store) = makeSUT()
		store.expectedCachedArticles = ([], Date())

		let received = try sut.load()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
		XCTAssertEqual(received, [])
	}

	func test_load_deliversCachedArticlesOnNonExpiredCache() throws {
		let expectedArticles = [uniqueArticle]
		let fixedCurrentDate = Date()
		let nonExpiredTimestamp = fixedCurrentDate.minusCacheMaxAge().adding(seconds: 1)

		let (sut, store) = makeSUT()

		store.expectedCachedArticles = (expectedArticles, nonExpiredTimestamp)

		let received = try sut.load()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
		XCTAssertEqual(received, expectedArticles)
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

	private func makeFailSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> LocalArticlesManager {
		let store = ArticlesCacheAlwaysFailStoreSpy()
		let sut = LocalArticlesManager(store: store, currentDate: { Date() })
		trackForMemoryLeaks(sut)
		trackForMemoryLeaks(store)
		return sut
	}
}

private extension Date {
	func minusCacheMaxAge() -> Date {
		return adding(days: -cacheMaxAgeInDays)
	}

	var cacheMaxAgeInDays: Int {
		return 1
	}
}
