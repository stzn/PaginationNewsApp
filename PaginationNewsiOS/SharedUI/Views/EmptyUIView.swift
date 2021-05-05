//
//  EmptyUIView.swift
//  PaginationNewsiOS
//
//  Created by Shinzan Takata on 2021/01/03.
//

import Combine
import UIKit

public final class EmptyUIView: UIView {
	private(set) lazy var messageLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.tintColor = .red
		label.font = .preferredFont(forTextStyle: .body)
		label.adjustsFontForContentSizeCategory = true
		label.numberOfLines = 0
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setup() {
		addSubview(messageLabel)
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			messageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
			messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
		])
	}

	public func setMessage(_ message: String?) {
		messageLabel.text = message
	}
}
