//
//  URLSessionHTTPClient.swift
//  PaginationNews
//

//

import Combine
import Foundation

public struct URLSessionHTTPClient: HTTPClient {
	private let session: URLSession
	public init(session: URLSession) {
		self.session = session
	}

	public func send(request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
		session.dataTaskPublisher(for: request)
			.tryMap { (data, response) in
				guard let httpResponse = response as? HTTPURLResponse else {
					throw URLError(.badServerResponse)
				}
				return (data, httpResponse)
			}
			.eraseToAnyPublisher()
	}
}
