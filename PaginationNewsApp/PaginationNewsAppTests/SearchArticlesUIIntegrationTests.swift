//
//  SearchArticlesUIIntegrationTests.swift
//  PaginationNewsAppTests
//
//

import XCTest
@testable import PaginationNewsApp
@testable import PaginationNews
@testable import PaginationNewsiOS

class SearchArticlesUIIntegrationTests: XCTestCase {
	func test_articlesView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, localized("VIEW_TITLE"))
	}

	func test_loadArticlesActions_doesNotDeliverWithoutKeyword() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadArticlesCallCount, 0, "Expected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadArticlesCallCount, 0, "Expected no loading requests once view is loaded")

		sut.simulateUserInitiatedArticlesReload()
		XCTAssertEqual(loader.loadArticlesCallCount, 0, "Expected no loading requests once user initiates a reload")
	}

	func test_loadArticlesActions_requestArticlesFromLoaderWithKeyword() {
		let expected = "test"
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadArticlesCallCount, 0, "Expected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadArticlesCallCount, 0, "Expected no loading requests once view is loaded")

		sut.simulateInputSearchText(expected)
		XCTAssertEqual(loader.loadArticlesCallCount, 1, "Expected a loading request when search text is not empty")
		XCTAssertEqual(loader.keyword(index: 0), expected, "Expected: \(expected) but got: \(loader.keyword(index: 0))")

		sut.simulateInputSearchText("")
		XCTAssertEqual(loader.loadArticlesCallCount, 1, "Expected no more loading requests when search text is empty")
	}

	func test_loadingArticlesIndicator_isVisibleWhileLoadingArticles() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

		loader.completeArticlesLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

		sut.simulateUserInitiatedArticlesReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

		loader.completeArticlesLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}

	func test_loadArticlesCompletion_rendersSuccessfullyLoadedArticles() {
		let article0 = uniqueArticle
		let article1 = uniqueArticle
		let article2 = uniqueArticle
		let article3 = uniqueArticle
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		assertThat(sut, isRendering: [])

		loader.completeArticlesLoading(with: [article0], at: 0)
		assertThat(sut, isRendering: [article0])

		sut.simulateUserInitiatedArticlesReload()
		loader.completeArticlesLoading(with: [article0, article1, article2, article3], at: 1)
		assertThat(sut, isRendering: [article0, article1, article2, article3])
	}

	func test_loadArticleCompletion_rendersSuccessfullyLoadedEmptyArticleAfterNonEmptyArticle() {
		let article0 = uniqueArticle
		let article1 = uniqueArticle
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [article0, article1], at: 0)
		assertThat(sut, isRendering: [article0, article1])

		sut.simulateUserInitiatedArticlesReload()
		loader.completeArticlesLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}

	func test_loadArticleCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let article0 = uniqueArticle
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [article0], at: 0)
		assertThat(sut, isRendering: [article0])

		sut.simulateUserInitiatedArticlesReload()
		loader.completeArticlesLoadingWithError(at: 1)
		assertThat(sut, isRendering: [article0])
	}

	func test_retryButtonTapOnErrorView_rendersLoadedArticles() {
		let article0 = uniqueArticle
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoadingWithError(at: 0)
		assertThat(sut, isRendering: [])
		XCTAssertNotNil(sut.errorView.errorLabel.text)

		sut.simulateRetryOnError()
		loader.completeArticlesLoading(with: [article0], at: 1)
		assertThat(sut, isRendering: [article0])
		XCTAssertNil(sut.errorView.errorLabel.text)
	}

	func test_loadArticleCompletion_showsErrorView() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoadingWithError(at: 0)
		assertThat(sut, isRendering: [])
		XCTAssertNotNil(sut.errorView.errorLabel.text)
	}

	func test_loadArticleCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeArticlesLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, sharedLocalized("VIEW_CONNECTION_ERROR"))

		sut.simulateUserInitiatedArticlesReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_articleImageView_loadsImageURLWhenVisible() {
		let article0 = uniqueArticle
		let article1 = uniqueArticle
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [article0, article1])

		XCTAssertEqual(loader.loadedImageURLs, [], "Expected no article URL requests until views become visible")

		sut.simulateArticleViewVisible(at: 0)
		XCTAssertEqual(loader.loadedImageURLs, [article0.urlToImage], "Expected first article URL request once first view becomes visible")

		sut.simulateArticleViewVisible(at: 1)
		XCTAssertEqual(loader.loadedImageURLs, [article0.urlToImage, article1.urlToImage], "Expected second article URL request once second view also becomes visible")
	}

	func test_articleView_cancelsImageLoadingWhenNotVisibleAnymore() {
		let article0 = uniqueArticle
		let article1 = uniqueArticle
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [article0, article1])
		XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")

		sut.simulateArticleViewNotVisible(at: 0)
		XCTAssertEqual(loader.cancelledImageURLs, [article0.urlToImage], "Expected one cancelled image URL request once first image is not visible anymore")

		sut.simulateArticleViewNotVisible(at: 1)
		XCTAssertEqual(loader.cancelledImageURLs, [article0.urlToImage, article1.urlToImage], "Expected two cancelled image URL requests once second image is also not visible anymore")
	}

	func test_articleViewLoadingIndicator_isVisibleWhileLoadingImage() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [uniqueArticle, uniqueArticle])

		let view0 = sut.simulateArticleViewVisible(at: 0)
		let view1 = sut.simulateArticleViewVisible(at: 1)
		XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
		XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")

		loader.completeImageLoading(at: 0)
		XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
		XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")

		loader.completeImageLoadingWithError(at: 1)
		XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
		XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
	}

	func test_articleView_rendersImageLoadedFromURL() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [uniqueArticle, uniqueArticle])

		let view0 = sut.simulateArticleViewVisible(at: 0)
		let view1 = sut.simulateArticleViewVisible(at: 1)
		XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
		XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")

		let imageData0 = UIImage.make(withColor: .red).pngData()!
		loader.completeImageLoading(with: imageData0, at: 0)
		XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
		XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")

		let imageData1 = UIImage.make(withColor: .blue).pngData()!
		loader.completeImageLoading(with: imageData1, at: 1)
		XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
		XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
	}

	func test_articleViewImageForError_isVisibleOnImageURLLoadError() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [uniqueArticle, uniqueArticle])

		let view0 = sut.simulateArticleViewVisible(at: 0)
		let view1 = sut.simulateArticleViewVisible(at: 1)
		XCTAssertNil(view0?.renderedImage, "Expected no image for first view while loading first image")
		XCTAssertNil(view1?.renderedImage, "Expected no image for second view while loading second image")

		let imageData = UIImage.make(withColor: .red).pngData()!
		loader.completeImageLoading(with: imageData, at: 0)
		XCTAssertEqual(view0?.renderedImage, imageData, "Expected image for first view once first image loading completes successfully")
		XCTAssertNil(view1?.renderedImage, "Expected no image change for second view once first image loading completes successfully")

		loader.completeImageLoadingWithError(at: 1)
		XCTAssertEqual(view0?.renderedImage, imageData, "Expected no image change for first view once second image loading completes with error")
		XCTAssertEqual(view1?.renderedImage, imageForError.pngData(), "Expected image for error for second view once second image loading completes with error")
	}

	func test_articleViewImageForError_isVisibleOnInvalidImageData() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [uniqueArticle, uniqueArticle])

		let view = sut.simulateArticleViewVisible(at: 0)
		XCTAssertNil(view?.renderedImage, "Expected no image for first view while loading first image")

		let invalidImageData = Data("invalid image data".utf8)
		loader.completeImageLoading(with: invalidImageData, at: 0)
		XCTAssertEqual(view?.renderedImage, imageForError.pngData(), "Expected image for error once image loading completes with invalid image data")
	}

	func test_articleView_preloadsImageURLWhenNearVisible() {
		let article0 = uniqueArticle
		let article1 = uniqueArticle
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [article0, article1])
		XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")

		sut.simulateArticleViewNearVisible(at: 0)
		XCTAssertEqual(loader.loadedImageURLs, [article0.urlToImage], "Expected first image URL request once first image is near visible")

		sut.simulateArticleViewNearVisible(at: 1)
		XCTAssertEqual(loader.loadedImageURLs, [article0.urlToImage, article1.urlToImage], "Expected second image URL request once second image is near visible")
	}

	func test_articleView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
		let article0 = uniqueArticle
		let article1 = uniqueArticle
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [article0, article1])
		XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")

		sut.simulateArticleViewNotNearVisible(at: 0)
		XCTAssertEqual(loader.cancelledImageURLs, [article0.urlToImage], "Expected first cancelled image URL request once first image is not near visible anymore")

		sut.simulateArticleViewNotNearVisible(at: 1)
		XCTAssertEqual(loader.cancelledImageURLs, [article0.urlToImage, article1.urlToImage], "Expected second cancelled image URL request once second image is not near visible anymore")
	}

	func test_loadArticlesCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeededWithSearchText()

		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeArticlesLoading(at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [uniqueArticle])
		_ = sut.simulateArticleViewVisible(at: 0)

		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeImageLoading(with: Data(), at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	func test_userScrollToBottom_requestsNextPage() {
		let (sut, loader) = makeSUT(perPageCount: 1)

		sut.loadViewIfNeededWithSearchText()
		XCTAssertEqual(loader.loadArticlesCallCount, 1)
		loader.completeArticlesLoading(with: [uniqueArticle], totalResults: 20)

		sut.simulateUserScrollToBottom()
		XCTAssertEqual(loader.loadArticlesCallCount, 2)
	}

	func test_userScrollToBottom_doesNotRequestNextPageOnLastPage() {
		let (sut, loader) = makeSUT(perPageCount: 20)

		sut.loadViewIfNeededWithSearchText()
		XCTAssertEqual(loader.loadArticlesCallCount, 1)
		loader.completeArticlesLoading(with: [uniqueArticle], totalResults: 20)

		sut.simulateUserScrollToBottom()
		XCTAssertEqual(loader.loadArticlesCallCount, 1)
	}

	func test_pagingRequest_appendsNextPage() {
		let article0 = uniqueArticle
		let article1 = uniqueArticle
		let (sut, loader) = makeSUT(perPageCount: 1)

		sut.loadViewIfNeededWithSearchText()
		loader.completeArticlesLoading(with: [article0], at: 0)
		assertThat(sut, isRendering: [article0])

		sut.simulateUserScrollToBottom()
		loader.completeArticlesLoading(with: [article1], at: 1)
		XCTAssertEqual(loader.loadArticlesCallCount, 2)
		assertThat(sut, isRendering: [article0, article1])
	}

	func test_userRefreshAction_afterPagingRequest_rendersOnlyTheFirstPage() {
		let article0 = uniqueArticle
		let article1 = uniqueArticle
		let article2 = uniqueArticle
		let (sut, loader) = makeSUT(perPageCount: 1)

		sut.loadViewIfNeededWithSearchText()

		loader.completeArticlesLoading(with: [article0], at: 0)
		assertThat(sut, isRendering: [article0])

		sut.simulateUserScrollToBottom()
		loader.completeArticlesLoading(with: [article1], at: 1)
		XCTAssertEqual(loader.loadArticlesCallCount, 2)
		assertThat(sut, isRendering: [article0, article1])

		sut.simulateUserInitiatedArticlesReload()
		loader.completeArticlesLoading(with: [article2], at: 2)
		XCTAssertEqual(loader.loadArticlesCallCount, 3)
		assertThat(sut, isRendering: [article2])
	}

	// MARK: - Helpers

	private func makeSUT(perPageCount: Int = APIConstants.articlesPerPageCount,
	                     file: StaticString = #filePath, line: UInt = #line) -> (sut: SearchArticlesViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = SearchArticlesUIComposer.articlesComposedWith(
			articlesLoader: loader.loadPublisher,
			imageLoader: loader.loadImageDataPublisher,
			perPageCount: perPageCount)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	private var uniqueArticle: Article {
		Article(id: UUID(),
		        author: "any author", title: "any title", description: "any description",
		        linkString: anyURL.absoluteString,
		        urlToImage: anyURL,
		        publishedAt: Date(timeIntervalSince1970: 0),
		        sourceName: "any source name")
	}

	private var anyURL: URL {
		URL(string: "http://any-url\(UUID().uuidString).com")!
	}

	private let imageForError = ArticleCellController.errorImage
}
