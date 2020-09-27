//
//  ArticleImagePresenterTests.swift
//  PaginationNewsTests
//
//  Created by Shinzan Takata on 2020/09/13.
//

import XCTest
@testable import PaginationNews

protocol ArticleImageView {
    associatedtype Image
    func display(_ viewModel: ArticleImageViewModel<Image>)
}

struct ArticleImageViewModel<Image> {
    let image: Image
    let isLoading: Bool
    let shouldRetry: Bool

}

final class ArticleImagePresenter<View: ArticleImageView, Image> where View.Image == Image {
    let view: View
    let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for article: Article) {

    }

    func didFinishLoadingImageData(with: Data, for: Article) {

    }

    func didFinishLoadingImageData(with error: Error, for: Article) {

    }

}

class ArticlePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueArticle

        sut.didStartLoadingImageData(for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }

    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueArticle

        sut.didFinishLoadingImageData(with: Data(), for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }

    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let image = uniqueImage()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

        sut.didFinishLoadingImageData(with: Data(), for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }

    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let image = uniqueImage()
        let (sut, view) = makeSUT()

        sut.didFinishLoadingImageData(with: anyNSError(), for: image)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }

    // MARK: - Helpers

    private func makeSUT(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ArticleImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = ArticleImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }

    private struct AnyImage: Equatable {}

    private class ViewSpy: ArticleImageView {
        private(set) var messages = [ArticleImageViewModel<AnyImage>]()

        func display(_ model: ArticleImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
}
