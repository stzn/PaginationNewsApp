//
//  HTTPClient.swift
//  PaginationNews
//

//

import Combine
import Foundation

public protocol HTTPClient {
	func send(request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error>
}
