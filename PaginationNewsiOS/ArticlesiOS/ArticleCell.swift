//
//  ArticleCell.swift
//  PaginationNews
//

//

import UIKit

public final class ArticleCell: UICollectionViewCell {
    lazy var articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    lazy var publishedAtLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    lazy var linkLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()

    let loadingIndicator = UIActivityIndicatorView(style: .large)

    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let containerStackView = UIStackView()

        // whole container
        do {
            containerStackView.axis = .vertical
            containerStackView.spacing = 8
            containerStackView.distribution = .fill
            contentView.addSubview(containerStackView)
            containerStackView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        }

        // title label
        containerStackView.addArrangedSubview(titleLabel)

        // summary
        do {
            let summaryContainerView = UIStackView()
            summaryContainerView.axis = .horizontal
            summaryContainerView.alignment = .center
            summaryContainerView.spacing = 8
            containerStackView.addArrangedSubview(summaryContainerView)
            summaryContainerView.translatesAutoresizingMaskIntoConstraints = false

            summaryContainerView.addArrangedSubview(articleImageView)
            articleImageView.translatesAutoresizingMaskIntoConstraints = false

            let detailStackView = UIStackView()
            detailStackView.axis = .vertical
            detailStackView.addArrangedSubview(authorLabel)
            detailStackView.addArrangedSubview(publishedAtLabel)
            detailStackView.addArrangedSubview(linkLabel)

            summaryContainerView.addArrangedSubview(detailStackView)
            detailStackView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                articleImageView.widthAnchor.constraint(equalTo: summaryContainerView.widthAnchor, multiplier: 0.4),
                articleImageView.widthAnchor.constraint(equalTo: articleImageView.heightAnchor),
            ])
        }

        // loading indicator
        do {
            contentView.addSubview(loadingIndicator)
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loadingIndicator.leadingAnchor.constraint(equalTo: articleImageView.leadingAnchor),
                loadingIndicator.trailingAnchor.constraint(equalTo: articleImageView.trailingAnchor),
                loadingIndicator.topAnchor.constraint(equalTo: articleImageView.topAnchor),
                loadingIndicator.bottomAnchor.constraint(equalTo: articleImageView.bottomAnchor),
            ])
        }

        // description
        containerStackView.addArrangedSubview(descriptionLabel)

        // separator
        containerStackView.addArrangedSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}
