//
//  WeakReference.swift
//  PaginationNews
//

//

import UIKit
import PaginationNews

final class WeakReference<T: AnyObject> {
	private weak var object: T?

	init(_ object: T) {
		self.object = object
	}
}

extension WeakReference: ErrorView where T: ErrorView {
	func display(_ viewModel: ErrorViewModel) {
		object?.display(viewModel)
	}
}

extension WeakReference: LoadingView where T: LoadingView {
	func display(_ viewModel: LoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakReference: ContentView where T: ContentView, T.ViewModel == UIImage? {
	func display(_ viewModel: UIImage?) {
		object?.display(viewModel)
	}
}
