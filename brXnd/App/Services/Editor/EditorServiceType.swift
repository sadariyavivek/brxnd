//
//  EditorServiceType.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

enum EditorServiceError: Error {
	case dataCorrupted
}

extension EditorServiceError: LocalizedError {
	public var localizedDescription: String {
		switch self {
		case .dataCorrupted:
			return "Editor data is corrupted"
		}
	}
}

protocol EditorServiceType {
	@discardableResult
	func getEditorSerializedData(id: ImageID) -> Single<Result<Data, Error>>

	@discardableResult
	func saveEditorSerializedData(id: ImageID, studioAsset: StudioAssetTuple)
		-> Single<Result<BRXNDEditorUploadResponse, Error>>

}
