//
//  UserNetworkAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct UserLoginAPI {
	let router = NetworkRouter<UserEndPoint>()
}

extension UserLoginAPI {

	func login(username: String, password: String,
			   completion: @escaping (Result<WebLogin, Error>) -> Void) {
		router.request(.login(username: username, password: password)) { data, response, err in

			if let err = err {
				completion(Result.failure(err))
				return
			}
			if let response = response as? HTTPURLResponse {
				let result = NetworkResponse.handleNetworkResponse(response)

				switch result {
				case .success:
					guard let data = data else {
                        print("+++++++++++++++ Failure")
                        completion(Result.failure(NetworkResponse.noData))
						return
					}
					do {
                        print("+++++++++++++++ Loged In")
						let apiResponse = try JSONDecoder().decode(WebLogin.self, from: data)
						completion(Result.success(apiResponse))
					} catch let err {
                        print("+++++++++++++++ error")
						completion(Result.failure(err))
					}
				case .failure(let networkFailureError):
                    print("+++++++++++++++ Network")
					completion(Result.failure(networkFailureError))
				}
			}
		}
	}
}

extension UserLoginAPI {
	func getToken(provider: ProviderToken,
				  completion: @escaping (Result<WebLogin, Error>) -> Void) {
		router.request(.getToken(provider: provider)) { data, response, error in
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
						let apiResponse = try JSONDecoder().decode(WebLogin.self, from: data)
						completion(Result.success(apiResponse))
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
