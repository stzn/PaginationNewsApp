//
//  UIViewController+Snapshot.swift
//  PaginationNewsiOSTests
//
//

import UIKit

extension UIViewController {
	func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
		SnapshotWindow(configuration: configuration, root: self).snapshot()
	}
}

struct SnapshotConfiguration {
	let size: CGSize
	let safeAreaInsets: UIEdgeInsets
	let layoutMargins: UIEdgeInsets
	let traitCollection: UITraitCollection

	static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
		.init(size: .init(width: 375, height: 667),
		      safeAreaInsets: .init(top: 20, left: 0, bottom: 0, right: 0),
		      layoutMargins: .init(top: 20, left: 16, bottom: 0, right: 16),
		      traitCollection: .init(traitsFrom: [
		      	.init(forceTouchCapability: .available),
		      	.init(layoutDirection: .leftToRight),
		      	.init(preferredContentSizeCategory: .medium),
		      	.init(userInterfaceIdiom: .phone),
		      	.init(horizontalSizeClass: .compact),
		      	.init(verticalSizeClass: .regular),
		      	.init(displayScale: 2),
		      	.init(displayGamut: .P3),
		      	.init(userInterfaceStyle: style)
		      ]))
	}
}

private final class SnapshotWindow: UIWindow {
	private var configuration: SnapshotConfiguration = .iPhone8(style: .light)

	convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
		self.init(frame: .init(origin: .zero, size: configuration.size))
		self.configuration = configuration
		self.layoutMargins = configuration.layoutMargins
		self.rootViewController = root
		self.isHidden = false
		root.view.layoutMargins = configuration.layoutMargins
	}

	override var traitCollection: UITraitCollection {
		.init(traitsFrom: [super.traitCollection, configuration.traitCollection])
	}

	func snapshot() -> UIImage {
		let renderer = UIGraphicsImageRenderer(bounds: bounds,
		                                       format: .init(for: traitCollection))
		return renderer.image { action in
			layer.render(in: action.cgContext)
		}
	}
}
