//
//  ArticlesMapper.swift
//  PaginationNews
//

//

import Foundation

public final class ArticlesMapper {
	private struct Root: Decodable {
		let status: String
		let totalResults: Int
		let articles: [Article]

		struct Article: Decodable {
			let source: Source
			let author: String?
			let title: String
			let description: String?
			let url: String?
			let urlToImage: String?
			let publishedAt: Date
			let content: String?

			struct Source: Decodable {
				let id: String?
				let name: String
			}

			var articleURL: URL? {
				if let urlToImage = urlToImage {
					return URL(string: urlToImage)
				}
				return nil
			}
		}

		var models: [PaginationNews.Article] {
			articles.map {
				PaginationNews.Article(id: UUID(),
				                       author: $0.author,
				                       title: $0.title,
				                       description: $0.description,
				                       linkString: $0.url,
				                       urlToImage: $0.articleURL,
				                       publishedAt: $0.publishedAt,
				                       sourceName: $0.source.name)
			}
		}
	}

	enum Error: Swift.Error {
		case invalidData
	}

	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> ([Article], Int) {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		decoder.dateDecodingStrategy = .iso8601

		guard isOK(response) else {
			throw Error.invalidData
		}
		do {
			let root = try decoder.decode(Root.self, from: data)
			guard root.status == "ok" else {
				throw Error.invalidData
			}

			return (root.models, root.totalResults)
		} catch {
			throw error
		}
	}

	private static func isOK(_ response: HTTPURLResponse) -> Bool {
		(200 ... 299).contains(response.statusCode)
	}
}
