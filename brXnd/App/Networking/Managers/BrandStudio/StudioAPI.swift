//
//  StudioAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-29.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct StudioAPI {
	let router: NetworkRouter = NetworkRouter<StudioAPIProvider>()
}

extension StudioAPI {
	func fetchBrandAssets(for id: String,
						  completion: @escaping (Result<BrandAssets, Error>) -> Void) {

		router.request(.fetchBrandAssets(id: id)) { (data, response, error) in
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
						completion(Result.success(try BrandAssets(data: data)))
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

extension StudioAPI {
	func fetchNextBrandAssets(for brandID: String, lastAssetID: Int,
							  completion: @escaping (Result<BrandAssets, Error>) -> Void) {
		router.request(.fetchNextBrandAssets(brandID: brandID, lastAssetID: lastAssetID)) { (data, response, error) in
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
						completion(Result.success(try BrandAssets(data: data)))
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

extension StudioAPI {
	func delete(studioItem id: String,
				completion: @escaping (Result<BRXNDCreateOrDeleteResponse, Error>) -> Void) {
		router.request(.delete(studioItemID: id)) { (data, response, error) in
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

extension StudioAPI {
	func uploadAsset(brandID: BrandID, studioAsset: Data,
					 completion: @escaping (Result<BRXNDStudioAssetUploadResponse, Error>) -> Void) {

		router.request(.uploadAsset(brandID: brandID, studioAsset: studioAsset)) { data, response, error in
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
						completion(Result.success(try BRXNDStudioAssetUploadResponse(data: data)))
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
