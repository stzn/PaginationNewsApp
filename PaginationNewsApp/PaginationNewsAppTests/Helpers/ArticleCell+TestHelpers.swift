//
//  ArticleCell+TestHelpers.swift
//  PaginationNewsAppTests
//
//

import UIKit
@testable import PaginationNewsiOS

extension ArticleCell {
	var isShowingImageLoadingIndicator: Bool {
		return loadingIndicator.isAnimating
	}

	var titleText: String? {
		return titleLabel.text
	}

	var authorText: String? {
		return authorLabel.text
	}

	var publishedAtText: String? {
		return publishedAtLabel.text
	}

	var linkText: String? {
		return linkLabel.text
	}

	var descriptionText: String? {
		return descriptionLabel.text
	}

	var renderedImage: Data? {
		return articleImageView.image?.pngData()
	}
}
