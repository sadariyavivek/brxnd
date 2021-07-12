//
//  EditorAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct EditorAPI {
	let router = NetworkRouter<EditorAPIProvider>()
}

extension EditorAPI {
	func getEditorSerializedData(id: ImageID, completion: @escaping (Result<Data, Error>) -> Void) {
		router.request(.getEditorSerializedData(id: id)) { data, response, error in
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
					completion(Result.success(data))
				case .failure(let networkFailureError):
					completion(Result.failure(networkFailureError))
				}
			}
		}
	}
}

extension EditorAPI {
	func saveEditorSerializedData(id: ImageID, studioAsset: StudioAssetTuple,
								  completion: @escaping (Result<BRXNDEditorUploadResponse, Error>) -> Void) {
		router.request(.saveEditorSerializedData(id: id, studioAsset: studioAsset)) { data, response, error in
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
						completion(Result.success(try BRXNDEditorUploadResponse(data: data)))
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
