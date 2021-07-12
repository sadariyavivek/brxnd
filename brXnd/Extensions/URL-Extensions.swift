//
//  URLExtensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-22.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension URL {
	func withQueries(_ queries: [String: String]) -> URL? {
		var components = URLComponents(url: self,
									   resolvingAgainstBaseURL: true)
		components?.queryItems = queries.compactMap { URLQueryItem(name: $0.0, value: $0.1) }
		return components?.url
	}
}

extension URL {
	func withHTTPS() -> URL? {
		var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
		components?.scheme = "https"
		return components?.url
	}
}
