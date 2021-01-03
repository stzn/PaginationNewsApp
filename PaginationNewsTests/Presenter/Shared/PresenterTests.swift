//
//  PresenterTests.swift
//  PaginationNewsTests
//
//

import XCTest
import PaginationNews

class PresenterTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: Presenter<Any, AnyView>.self)

        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingArticles_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoading()

        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }

    func test_didFinishLoadingArticles_displaysArticlesAndStopsLoading() {
        let (sut, view) = makeSUT()
        let viewModel = "model"

        sut.didFinishLoading(viewModel)

        XCTAssertEqual(view.messages, [
            .display(viewModel),
            .display(isLoading: false)
        ])
    }

    func test_didFinishLoadingArticlesWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()

        sut.didFinishLoading(with: anyNSError)

        XCTAssertEqual(view.messages, [
            .display(errorMessage: sharedLocalized("VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: Presenter<String, ViewSpy>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = Presenter<String, ViewSpy>(contentView: view, loadingView: view,
                                             errorView: view, mapper: { $0 } )
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Articles"
        let bundle = Bundle(for: ArticlesPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

    private func sharedLocalized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Shared"
        let bundle = Bundle(for: Presenter<Any, ViewSpy>.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

    private var uniqueArticles: [Article] {
        [
            uniqueArticle,
            uniqueArticle,
        ]
    }

    private class ViewSpy: ContentView, LoadingView, ErrorView {
        typealias ViewModel = String
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(String)
        }

        private(set) var messages = Set<Message>()

        func display(_ viewModel: ErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }

        func display(_ viewModel: LoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: ViewModel) {
            messages.insert(.display(viewModel))
        }
    }
}
