//
//  HTTPClientStub.swift
//  PaginationNewsAppTests
//
//  Created by Shinzan Takata on 2021/05/05.
//

import Combine
import Foundation
import PaginationNews

final class HTTPClientStub: HTTPClient {
	private let stub: (URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error>
	init(stub: @escaping (URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error>) {
		self.stub = stub
	}

	func send(request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
		return stub(request)
	}
}

extension HTTPClientStub {
	static func online(_ stub: @escaping (URLRequest) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
		HTTPClientStub(stub: { request in
			Just<(Data, HTTPURLResponse)>(stub(request))
				.setFailureType(to: Error.self)
				.eraseToAnyPublisher()
		})
	}

	static var offline: HTTPClientStub {
		.init(stub: { _ in Fail(error: NSError()).eraseToAnyPublisher() })
	}
}
