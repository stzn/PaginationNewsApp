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

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FileArticleImageDataCacheStore {
		let sut = FileArticleImageDataCacheStore(baseDirectroy: testDirectory)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func assertEmptyCache(
		on sut: FileArticleImageDataCacheStore,
		retriveCount: RetrieveCount,
		file: StaticString = #filePath, line: UInt = #line) throws {
		let article = uniqueArticle
		let cached = try sut.retrieve(for: article, count: retriveCount)

		XCTAssertNil(cached)
	}

	private func asserttNonEmptyCache(
		on sut: FileArticleImageDataCacheStore,
		retriveCount: RetrieveCount,
		file: StaticString = #filePath, line: UInt = #line) throws {
		let article = uniqueArticle
		let data = "test data".data(using: .utf8)!

		try sut.save(for: article.id.uuidString, data)
		let cached = try sut.retrieve(for: article, count: retriveCount)

		XCTAssertEqual(cached, data)
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
