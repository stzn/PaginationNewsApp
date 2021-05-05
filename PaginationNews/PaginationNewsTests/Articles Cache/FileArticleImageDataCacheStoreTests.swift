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
		let cached = try sut.retrieve(count: retriveCount)

		XCTAssertNil(cached)
	}
}

private enum RetrieveCount {
	case once, twice
}

private extension ArticleImageDataCacheStore {
	func retrieve(count: RetrieveCount) throws -> Data? {
		switch count {
		case .once:
			return try retrieve()
		case .twice:
			return try retrieveTwice()
		}
	}

	func retrieveTwice() throws -> Data? {
		_ = try retrieve()
		return try retrieve()
	}
}
