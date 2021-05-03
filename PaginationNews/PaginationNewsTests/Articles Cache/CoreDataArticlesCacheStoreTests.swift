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

		let articles = try sut.retrieve()

		XCTAssertNil(articles)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = makeSUT()

		_ = try sut.retrieve()
		let articles = try sut.retrieve()

		XCTAssertNil(articles)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let articles = [uniqueArticle]
		let timestamp = Date()
		let sut = makeSUT()

		try sut.save(articles, timestamp)
		let cached = try sut.retrieve()

		XCTAssertEqual(cached?.articles, articles)
		XCTAssertEqual(cached?.timestamp, timestamp)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
		let articles = [uniqueArticle]
		let timestamp = Date()
		let sut = makeSUT()

		try sut.save(articles, timestamp)
		_ = try sut.retrieve()
		let cached = try sut.retrieve()

		XCTAssertEqual(cached?.articles, articles)
		XCTAssertEqual(cached?.timestamp, timestamp)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataArticlesCacheStore {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try! CoreDataArticlesCacheStore(storeURL: storeURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
}
