//
//  UIButton+TestHelpers.swift
//  PaginationNewsAppTests
//
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
