//
//  PagesEndPoint.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-27.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

enum PagesAPIProvider {
	case facebookPages
}

extension PagesAPIProvider: EndPointType {
	var baseURL: URL {
		let url = BRXNDBaseURL.url
		return url
	}

	var path: String {
		switch self {
		case .facebookPages:
			return "/api/v1/instagram-posts"
		}
	}

	var httpMethod: HTTPMethod {
		return .get
	}

	var task: HTTPTask {

		switch self {
		case .facebookPages:
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .none,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())
		}
	}
	var headers: HTTPHeaders? {
		return nil
	}
}
