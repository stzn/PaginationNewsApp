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

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataArticlesCacheStore {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try! CoreDataArticlesCacheStore(storeURL: storeURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
}
