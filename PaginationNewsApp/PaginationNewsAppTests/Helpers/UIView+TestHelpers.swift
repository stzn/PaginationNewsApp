//
//  UIView+TestHelpers.swift
//  PaginationNewsAppTests
//
//

import UIKit

extension UIView {
	func enforceLayoutCycle() {
		layoutIfNeeded()
		RunLoop.current.run(until: Date())
	}
}
