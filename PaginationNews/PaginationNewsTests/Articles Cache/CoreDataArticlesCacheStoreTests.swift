//
//  CoreDataArticlesCacheStoreTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/03.
//

import XCTest
import PaginationNews

class CoreDataArticlesCacheStoreTests: XCTestCase {
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = makeSUT()

		try assertEmptyCache(on: sut, retriveCount: .once)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = makeSUT()

		try assertEmptyCache(on: sut, retriveCount: .twice)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let sut = makeSUT()

		try asserttNonEmptyCache(on: sut, retriveCount: .once)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
		let sut = makeSUT()

		try asserttNonEmptyCache(on: sut, retriveCount: .twice)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		XCTAssertNoThrow(try sut.save([], Date()))
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		XCTAssertNoThrow(try sut.save([uniqueArticle], Date()))
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
		let sut = makeSUT()

		try assertOverrideCachedValue(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		XCTAssertNoThrow(try sut.delete())
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
		let sut = makeSUT()

		try assertDeleteOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
		let sut = makeSUT()

		try assertDeleteOnNonEmptyCache(on: sut)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> ArticlesCacheStore {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try! CoreDataArticlesCacheStore(storeURL: storeURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func assertEmptyCache(
		on sut: ArticlesCacheStore,
		retriveCount: RetrieveCount,
		file: StaticString = #filePath, line: UInt = #line) throws {
		let cached = try sut.retrieve(count: retriveCount)

		XCTAssertNil(cached)
	}

	private func asserttNonEmptyCache(
		on sut: ArticlesCacheStore,
		retriveCount: RetrieveCount,
		file: StaticString = #filePath, line: UInt = #line) throws {
		let articles = [uniqueArticle]
		let timestamp = Date()

		try sut.save(articles, timestamp)
		let cached = try sut.retrieve(count: retriveCount)

		XCTAssertEqual(cached?.articles, articles)
		XCTAssertEqual(cached?.timestamp, timestamp)
	}

	private func assertOverrideCachedValue(
		on sut: ArticlesCacheStore,
		file: StaticString = #filePath, line: UInt = #line) throws {
		try sut.save([uniqueArticle], Date())
		try asserttNonEmptyCache(on: sut, retriveCount: .once)
	}

	private func assertDeleteOnEmptyCache(
		on sut: ArticlesCacheStore,
		file: StaticString = #filePath, line: UInt = #line) throws {
		try sut.delete()

		try assertEmptyCache(on: sut, retriveCount: .once)
	}

	private func assertDeleteOnNonEmptyCache(
		on sut: ArticlesCacheStore,
		file: StaticString = #filePath, line: UInt = #line) throws {
		try sut.save([uniqueArticle], Date())
		try sut.delete()

		try assertEmptyCache(on: sut, retriveCount: .once)
	}
}

private enum RetrieveCount {
	case once, twice
}

private extension ArticlesCacheStore {
	func retrieve(count: RetrieveCount) throws -> CachedArticles? {
		switch count {
		case .once:
			return try retrieve()
		case .twice:
			return try retrieveTwice()
		}
	}

	func retrieveTwice() throws -> CachedArticles? {
		_ = try retrieve()
		return try retrieve()
	}
}
