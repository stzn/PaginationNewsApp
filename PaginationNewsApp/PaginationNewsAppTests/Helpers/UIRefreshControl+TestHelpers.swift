//
//  UIRefreshControl+TestHelpers.swift
//  PaginationNewsAppTests
//
//

import UIKit

extension UIRefreshControl {
	func simulatePullToRefresh() {
		simulate(event: .valueChanged)
	}
}
