//
//  ErrorViewModel.swift
//  PaginationNews
//

//

import Foundation

public struct ErrorViewModel {
    public let message: String?
    public let retryButtonTitle: String?

    static var noError: ErrorViewModel {
        return ErrorViewModel(message: nil, retryButtonTitle: nil)
    }

    static func error(message: String, retryButtonTitle: String) -> ErrorViewModel {
        return ErrorViewModel(message: message, retryButtonTitle: retryButtonTitle)
    }
}
