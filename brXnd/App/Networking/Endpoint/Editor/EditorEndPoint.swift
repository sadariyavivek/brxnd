//
//  EditorEndPoint.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

public typealias ImageID = Int

public struct StudioAssetTuple {
	let imageAsData: Data
	let editorData: Data
}

extension StudioAssetTuple {
	func encodedAsJSONString() -> (String, Any) {
		let editorData = try! JSONSerialization.jsonObject(with: self.editorData, options: [])
		return (self.imageAsData.base64EncodedString(), editorData)
	}
}

public enum EditorAPIProvider {
	case getEditorSerializedData(id: ImageID)
	case saveEditorSerializedData(id: ImageID, studioAsset: StudioAssetTuple)
}

extension EditorAPIProvider: EndPointType {

	var baseURL: URL {
		return BRXNDBaseURL.url
	}

	var path: String {
		switch self {
		case .getEditorSerializedData(let id):
			return "api/v1/get-image-data/\(id)"
		case .saveEditorSerializedData(let tuple):
			return "api/v1/save-now-media/\(tuple.id)"
		}
	}

	var httpMethod: HTTPMethod {
		switch self {
		case .getEditorSerializedData:
			return .get
		case .saveEditorSerializedData:
			return .patch
		}
	}

	var task: HTTPTask {

		switch self {
		case .getEditorSerializedData:
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .none,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())

		case .saveEditorSerializedData(_, let tuple):
			let tupleEncoded = tuple.encodedAsJSONString()
			return .requestParametersAndHeaders(bodyParameters: ["template": tupleEncoded.1,
																 "file": tupleEncoded.0],
												bodyEncoding: .jsonEncoding,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())
		}
	}
	var headers: HTTPHeaders? {
		return nil
	}
}
