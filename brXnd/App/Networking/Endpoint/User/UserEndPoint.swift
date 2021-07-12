//
//  UserEndPoint.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

enum ProviderToken {
	case fromFacebook(String)
}

enum UserEndPoint {
	case login(username: String, password: String)
	case registration(username: String, password: String,
		email: String)
	case getToken(provider: ProviderToken)
	case getUserInfo

	case facebookUserDataUpload(email: String, name: String, token: String, avatar: String? = nil)
}

extension UserEndPoint: EndPointType {
	
	var baseURL: URL {
		let url = BRXNDBaseURL.url 
		return url
	}

	var path: String {
		switch self {
		case .login, .getToken:
			return "/oauth/token"
		case .registration:
			return "/register"
		case .getUserInfo:
			return "api/v1/current-user"
		case .facebookUserDataUpload:
			return "api/v1/ios-register"
		}
	}

	var httpMethod: HTTPMethod {
		switch self {
		case .login, .registration, .getToken, .facebookUserDataUpload:
			return .post
		case .getUserInfo:
			return .get
		}
	}

	var task: HTTPTask {

		switch self {
		case .login(let username, let password):
			return .requestParameters(bodyParameters: 	["grant_type": "password",
														   "client_secret": BrXndAPISecret.clientSecret,
														   "username": "\(username)",
				"password": "\(password)",
				"client_id": "2"],
									  bodyEncoding: .jsonEncoding,
									  urlParameters: nil)
			
		case .registration(let username, let password, let email):
			return .requestParameters(bodyParameters: 	["name": "\(username)",
				"email": "\(email)",
				"password": "\(password)",
				"password_confirmation": "\(password)"],
									  bodyEncoding: .jsonEncoding,
									  urlParameters: nil)
		case .getUserInfo:
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .none,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())
		case .getToken(provider: let providerToken):
			switch providerToken {
			case .fromFacebook(let token):
				return .requestParameters(bodyParameters: ["grant_type": "social",
														   "client_id": "2",
														   "client_secret": BrXndAPISecret.clientSecret,
														   "provider": "facebook",
														   "access_token": "\(token)"],
										  bodyEncoding: .jsonEncoding,
										  urlParameters: nil)
			}
		//TODO: add avatar
		case .facebookUserDataUpload(let email, let name, let token, _):
			return .requestParametersAndHeaders(bodyParameters:
				[
					"email": "\(email)",
					"name": "\(name)",
					"token": "\(token)",
					"avatar": ""],
												bodyEncoding: .jsonEncoding,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())

		}
	}
	
	var headers: HTTPHeaders? {
		return nil
	}
}
