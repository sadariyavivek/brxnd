//
//  PostsAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct PostsAPI {
	let router: NetworkRouter = NetworkRouter<PostsAPIProvider>()
}

extension PostsAPI {
	func getPosts(for facebookPageID: PageID,
				  completion: @escaping (Result<FBPosts, Error>) -> Void) {

		router.request(.retrievePostsFor(facebookPageID)) { (data, response, error) in
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
						completion(Result.success(try FBPosts(data: data)))
					} catch let err {
						completion(Result.failure(err))
					}
				case .failure(let networkFailureError):
					completion(Result.failure(networkFailureError))
				}
			}
		}
	}
    
    func getPostsInsta(completion: @escaping (Result<InstaPosts, Error>) -> Void) {

        router.request(.retrieveInstaPostsFor) { (data, response, error) in
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
                        completion(Result.success(try InstaPosts(data: data)))
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

extension PostsAPI {
	func deletePost(for identifier: PostIdentifier,
					completion: @escaping (Result<String, Error>) -> Void ) {

		router.request(.deletePost(identifier)) { (data, response, error) in
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
					completion(Result.success(String(describing: data)))
				case .failure(let err):
					completion(Result.failure(err))
				}
			}
		}
	}
}

extension PostsAPI {
	func getNextPosts(for pageID: String, cursor: String,
					  completion: @escaping (Result<FBPostsPaginated, Error>) -> Void) {

		router.request(.retrievePaginatedPostsFor(PaginationTuple(pageID, cursor))) { (data, response, error) in
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
						completion(Result.success(try FBPostsPaginated(data: data)))
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

extension PostsAPI {
	func newPost(with post: NewPost,
				 completion: @escaping (Result<BRXNDCreateOrDeleteResponse, Error>) -> Void) {

		router.request(.newPost(post)) { (data, response, error) in
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
