//
//  ArticlesViewAdapter.swift
//  PaginationNews
//

//

import Combine
import UIKit
import PaginationNews
import PaginationNewsiOS

let imageForError = UIImage(named: "noImage")!

final class ArticlesViewAdapter: ContentView {
    private weak var controller: ArticlesViewController?
    private let imageLoader: (URL) -> AnyPublisher<Data, Error>
    private typealias PresentationAdapter = ImageDataPresentationAdapter<WeakReference<ArticleCellController>>

    init(controller: ArticlesViewController, imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: ArticlesViewModel) {
        if viewModel.pageNumber == 1 {
            controller?.set(viewModel.articles.map(map))
        } else {
            controller?.append(viewModel.articles.map(map))
        }
    }

    private func map(_ model: Article) -> ArticleCellController {
        let adapter = PresentationAdapter { model.urlToImage != nil ?
                    self.imageLoader(model.urlToImage!)
                    : self.noImagePublisher
        }
        let view = ArticleCellController(viewModel: ArticlePresenter.map(model),
                                         errorImage: imageForError,
                                         delegate: adapter)

        adapter.presenter = Presenter(
            contentView: WeakReference(view),
            loadingView: WeakReference(view),
            errorView: WeakReference(view),
            mapper: UIImage.tryMap)

        return view
    }

    private var noImagePublisher: AnyPublisher<Data, Error> {
        Just(imageForError.pngData()!).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

extension UIImage {
    struct InvalidData: Error {}

    static func tryMap(_ data: Data) throws -> UIImage {
        if let image = UIImage(data: data) {
            return image
        } else {
            throw InvalidData()
        }
    }
}

private final class PublishedAtDateFormatter {
    static var formatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        return formatter
    }()

    static func format(from date: Date, relativeTo standard: Date = Date()) -> String {
        formatter.localizedString(for: date, relativeTo: standard)
    }
}

