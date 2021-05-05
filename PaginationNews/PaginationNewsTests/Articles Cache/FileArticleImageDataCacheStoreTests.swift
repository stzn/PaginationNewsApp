//
//  FileArticleImageDataCacheStoreTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/04.
//

import XCTest
import PaginationNews

class FileArticleImageDataCacheStoreTests: XCTestCase {
	private let testDirectory = FileManager.default.temporaryDirectory
		.appendingPathComponent("FileArticleImageDataCacheStoreTests")

	override func setUpWithError() throws {
		try super.setUpWithError()
		if FileManager.default.fileExists(atPath: testDirectory.path) {
			try FileManager.default.removeItem(at: testDirectory)
		}
		try FileManager.default.createDirectory(at: testDirectory,
		                                        withIntermediateDirectories: true)
	}

	override func tearDownWithError() throws {
		try super.tearDownWithError()
		if FileManager.default.fileExists(atPath: testDirectory.path) {
			try FileManager.default.removeItem(at: testDirectory)
		}
	}

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

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()
		let data = "test data".data(using: .utf8)!

		XCTAssertNoThrow(try sut.save(for: "any key", data))
	}

	func test_insert_overridesPreviouslyInsertedCacheValue() throws {
		let sut = makeSUT()

		try assertOverrideCachedValue(on: sut)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> ArticleImageDataCacheStore {
		let sut = FileArticleImageDataCacheStore(baseDirectroy: testDirectory)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func assertEmptyCache(
		on sut: ArticleImageDataCacheStore,
		retriveCount: RetrieveCount,
		file: StaticString = #filePath, line: UInt = #line) throws {
		let article = uniqueArticle
		let cached = try sut.retrieve(for: article, count: retriveCount)

		XCTAssertNil(cached)
	}

	private func asserttNonEmptyCache(
		on sut: ArticleImageDataCacheStore,
		retriveCount: RetrieveCount,
		file: StaticString = #filePath, line: UInt = #line) throws {
		let article = uniqueArticle
		let data = "test data".data(using: .utf8)!

		try sut.save(for: article.id.uuidString, data)
		let cached = try sut.retrieve(for: article, count: retriveCount)

		XCTAssertEqual(cached, data)
	}

	private func assertOverrideCachedValue(
		on sut: ArticleImageDataCacheStore,
		file: StaticString = #filePath, line: UInt = #line) throws {
		try sut.save(for: UUID().uuidString, "random data".data(using: .utf8)!)
		try asserttNonEmptyCache(on: sut, retriveCount: .once)
	}
}

private enum RetrieveCount {
	case once, twice
}

private extension ArticleImageDataCacheStore {
	func retrieve(for article: Article, count: RetrieveCount) throws -> Data? {
		switch count {
		case .once:
			return try retrieve(for: article.idString)
		case .twice:
			return try retrieveTwice(for: article)
		}
	}

	func retrieveTwice(for article: Article) throws -> Data? {
		_ = try retrieve(for: article.idString)
		return try retrieve(for: article.idString)
	}
}
