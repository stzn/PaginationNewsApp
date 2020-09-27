//
//  ErrorViewModel.swift
//  PaginationNews
//

//

import Foundation

public struct ErrorViewModel {
    public let message: String?

    static var noError: ErrorViewModel {
        return ErrorViewModel(message: nil)
    }

    static func error(message: String) -> ErrorViewModel {
        return ErrorViewModel(message: message)
    }
}
