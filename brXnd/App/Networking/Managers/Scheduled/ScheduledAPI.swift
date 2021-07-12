//
//  ScheduledAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-23.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct ScheduledAPI {
	let router: NetworkRouter = NetworkRouter<ScheduleAPIProvider>()
}

extension ScheduledAPI {
	func getScheduledPosts(for facebookPageID: PageID,
						   completion: @escaping (Result<FBPostsScheduled, Error>) -> Void) {

		router.request(.scheduledFacebookPostFor(facebookPageID)) { (data, response, error) in
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
						completion(Result.success(try FBPostsScheduled(data: data)))
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

extension ScheduledAPI {
	func publishScheduledPostNow(for postIdentifier: PostIdentifier,
								 completion: @escaping (Result<BRXNDCreateOrDeleteResponse, Error>) -> Void) {

		router.request(.publishScheduledPostNow(postIdentifier)) { data, response, error in
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
						completion(Result.success(try BRXNDCreateOrDeleteResponse(data: data)))
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
