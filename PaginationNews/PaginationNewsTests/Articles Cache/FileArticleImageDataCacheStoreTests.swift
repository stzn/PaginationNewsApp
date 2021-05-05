//
//  FileArticleImageDataCacheStoreTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2021/05/04.
//

import XCTest
import PaginationNews

class FileArticleImageDataCacheStoreTests: XCTestCase {
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = makeSUT()

		try assertEmptyCache(on: sut, retriveCount: .once)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = makeSUT()

		try assertEmptyCache(on: sut, retriveCount: .twice)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FileArticleImageDataCacheStore {
		let testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("FileArticleImageDataCacheStoreTests")
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
