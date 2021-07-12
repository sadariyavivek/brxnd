//
//  JSONParameterEncoder.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-25.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

public struct JSONParameterEncoder: ParameterEncoder {
	public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
		do {
			if #available(iOS 13.0, *) {
				let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: [.withoutEscapingSlashes, .prettyPrinted])
				urlRequest.httpBody = jsonAsData
				if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
					urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
				}
			} else {
                let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
                urlRequest.httpBody = jsonAsData
                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
				//TODO: Fix!
				//fatalError("Implement escaping slashes")
			}

		} catch {
			throw NetworkError.encodingFailed
		}
	}
}
