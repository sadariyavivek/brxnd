//
//  UserValidationEndPoint.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-04-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

/* - Not fully used! */

enum UserValidation {
	case emailAvailable(email: String)
	case validateEmail(email: String)
}

extension UserValidation: EndPointType {
	
	var baseURL: URL {
		let url = BRXNDBaseURL.url
		return url
	}

	var path: String {
		switch self {
		case .emailAvailable:
			return "/check-email"
		case .validateEmail:
			return "/check-email-verified"
		}
	}

	var httpMethod: HTTPMethod {
		return .post
	}

	var task: HTTPTask {
		switch self {
		case .emailAvailable(let email):
			return .requestParameters(bodyParameters: ["email": "\(email)"],
									  bodyEncoding: .jsonEncoding,
									  urlParameters: nil)
		case .validateEmail(let email):
			return .requestParameters(bodyParameters: ["email": "\(email)"],
									  bodyEncoding: .jsonEncoding,
									  urlParameters: nil)
		}
	}

	var headers: HTTPHeaders? {
		return nil
	}
}
/* - Not fully used! */
