//
//  ErrorView.swift
//  PaginationNews
//
//

import Combine
import UIKit

final class ErrorUIView: UIView {
    private lazy var container: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.addArrangedSubview(errorLabel)
        stack.addArrangedSubview(retryButton)
        return stack
    }()

    private(set) lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .systemRed
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        return label
    }()

    private let retrySubject = PassthroughSubject<Void, Never>()
    var retryPublisher: AnyPublisher<Void, Never> {
        retrySubject.eraseToAnyPublisher()
    }

    private(set) lazy var retryButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                              multiplier: 0.8)
        ])
    }

    func setMessage(_ message: String?, retryButtonTitle: String?) {
        errorLabel.text = message
        retryButton.setTitle(retryButtonTitle, for: .normal)
    }

    @objc private func retry() {
        self.retrySubject.send()
    }
}

