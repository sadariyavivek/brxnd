//
//  UserValidationAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-04-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct UserValidationAPI {
	let router = NetworkRouter<UserValidation>()
}

extension UserValidationAPI {
	func validate(userValidationType: UserValidation,
					   completion: @escaping (Result<String, Error>) -> Void) {

		//clear cookies before each req
		HTTPCookieStorage
			.shared
			.cookies?
			.forEach {HTTPCookieStorage.shared.deleteCookie($0)}

		router.request(userValidationType) { (data, response, error) in

			if let error = error {
				completion(Result.failure(error))
				return
			}

			if let response = response as? HTTPURLResponse {
				let result 	= NetworkResponse.handleNetworkResponse(response)

				switch result {
				case .success:
					guard let data = data else {
						return completion(Result.failure(NetworkResponse.noData))
					}
					do {
						let json 		= try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
						let apiResponse = json?["status"] as? String

						if let apiResponse = apiResponse {
							completion(Result.success(apiResponse))
						} else {
							completion(Result.failure(NSError(domain: "Can't parse the response", code: 0, userInfo: nil)))
						}
					} catch let error {
						completion(Result.failure(error))
					}

				case .failure(let networkFailureError):
					completion(Result.failure(networkFailureError))
				}
			}
		}
	}
}
