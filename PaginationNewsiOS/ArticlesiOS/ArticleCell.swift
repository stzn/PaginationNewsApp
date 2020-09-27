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
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        return label
    }()

    let authorLabel = UILabel()
    let publishedAtLabel = UILabel()

    lazy var linkLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    let loadingIndicator = UIActivityIndicatorView(style: .large)

    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
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
            let summaryContainerView = UIView()
            containerStackView.addArrangedSubview(summaryContainerView)
            containerStackView.translatesAutoresizingMaskIntoConstraints = false

            summaryContainerView.addSubview(articleImageView)
            articleImageView.translatesAutoresizingMaskIntoConstraints = false

            let detailStackView = UIStackView()
            detailStackView.axis = .vertical
            detailStackView.addArrangedSubview(authorLabel)
            detailStackView.addArrangedSubview(publishedAtLabel)
            detailStackView.addArrangedSubview(linkLabel)

            summaryContainerView.addSubview(detailStackView)
            detailStackView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                summaryContainerView.leadingAnchor.constraint(equalTo: articleImageView.leadingAnchor),
                summaryContainerView.topAnchor.constraint(equalTo: articleImageView.topAnchor),
                summaryContainerView.bottomAnchor.constraint(equalTo: articleImageView.bottomAnchor),
                detailStackView.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 8),
                detailStackView.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor),
                detailStackView.topAnchor.constraint(equalTo: summaryContainerView.topAnchor),
                detailStackView.bottomAnchor.constraint(equalTo: summaryContainerView.bottomAnchor),
                articleImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
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
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    func resetUI() {
        articleImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        publishedAtLabel.text = nil
        linkLabel.text = nil
        descriptionLabel.text = nil
    }
}
