//
//  PagesAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-27.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct PagesAPI {
	let router: NetworkRouter = NetworkRouter<PagesAPIProvider>()
}

extension PagesAPI {
	func getPages(completion: @escaping (Result<[PostPage], Error>) -> Void) {
		router.request(.facebookPages) { (data, response, error) in
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
						let jsonDecoder = JSONDecoder()
						let postPages 	= try jsonDecoder.decode([PostPage].self, from: data)
						completion(Result.success(postPages))
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
