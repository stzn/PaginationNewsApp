//
//  UIView+TestHelpers.swift
//  PaginationNewsiOSTests
//
//  Created by Shinzan Takata on 2020/10/11.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}

