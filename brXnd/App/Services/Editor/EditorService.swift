//
//  EditorService.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct EditorService: EditorServiceType {

	private let editorAPI: EditorAPI

	init(editorAPI: EditorAPI = EditorAPI()) {
		self.editorAPI = editorAPI
	}

	func getEditorSerializedData(id: ImageID) -> Single<Result<Data, Error>> {
		return editorAPI
			.rx
			.getEditorSerializedData(id: id)
			.retry(1)
			.timeout(.seconds(15), scheduler: MainScheduler.instance)
//			.map {
//				switch $0 {
//				case .success(let value):
//					if JSONSerialization.isValidJSONObject(value) {
//						return $0
//					} else {
//						throw EditorServiceError.dataCorrupted
//					}
//				case .failure:
//					return $0
//				}
//		}
	}

	func saveEditorSerializedData(id: ImageID, studioAsset: StudioAssetTuple)
		-> Single<Result<BRXNDEditorUploadResponse, Error>> {
		return editorAPI
				.rx
				.saveEditorSerializedData(id: id, studioAsset: studioAsset)
				.retry(1)
				.timeout(.seconds(10), scheduler: MainScheduler.instance)
	}
}
