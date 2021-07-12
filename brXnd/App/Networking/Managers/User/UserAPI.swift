//
//  UserAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct UserAPI {
	let router = NetworkRouter<UserEndPoint>()
}

extension UserAPI {
	func getUserInfo(
		completion: @escaping (Result<UserResponse, Error>) -> Void) {
		router.request(.getUserInfo) { data, response, error in
			if let err = error {
				completion(Result.failure(err))
				return
			}
			if let response = response as? HTTPURLResponse {
				let result = NetworkResponse.handleNetworkResponse(response)
				switch result {
				case .success:
					guard let data = data else { completion(Result.failure(NetworkResponse.noData))
						return
					}
					do {
						completion(Result.success(try UserResponse(data: data)))
					} catch let err {
						completion(Result.failure(err))
					}
				case .failure(let networkFailureError):
					completion(Result.failure(networkFailureError))
				}
			}
		}
	}
}
