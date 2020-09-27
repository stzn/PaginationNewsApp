//
//  Presenter.swift
//  PaginationNews
//
//

import Foundation

public protocol LoadingView {
    func display(_ viewModel: LoadingViewModel)
}

public protocol ErrorView {
    func display(_ viewModel: ErrorViewModel)
}

public protocol ContentView {
    associatedtype ViewModel
    func display(_ viewModel: ViewModel)
}

public final class Presenter<Content, View: ContentView> {
    let contentView: View
    let loadingView: LoadingView
    let errorView: ErrorView
    let mapper: (Content) throws -> View.ViewModel

    var loadError: String {
        return NSLocalizedString("VIEW_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Error message displayed when we can't load the article from the server")
    }

    var retryButtonTitle: String {
        return NSLocalizedString("RETRY_BUTTON",
                                 tableName: "Shared",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Retry button displayed when we can't load the article from the server")
    }

    public init(contentView: View,
         loadingView: LoadingView,
         errorView: ErrorView,
         mapper: @escaping (Content) throws -> View.ViewModel) {
        self.contentView = contentView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }

    public func didStartLoading() {
        errorView.display(.init(message: nil, retryButtonTitle: nil))
        loadingView.display(.init(isLoading: true))
    }

    public func didFinishLoading(_ content: Content) {
        loadingView.display(.init(isLoading: false))
        do {
            contentView.display(try mapper(content))
        } catch {
            errorView.display(.init(message: error.localizedDescription,
                                    retryButtonTitle: retryButtonTitle))
        }
    }

    public func didFinishLoading(with error: Error) {
        errorView.display(.init(message: loadError,
                                retryButtonTitle: retryButtonTitle))
        loadingView.display(.init(isLoading: false))
    }

}
