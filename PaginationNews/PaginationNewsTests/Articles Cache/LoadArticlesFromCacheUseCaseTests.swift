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
}

final class ArticlesCacheStoreSpy {
    var receivedMessages: [String] = []
}

class LoadArticlesFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
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
