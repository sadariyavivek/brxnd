//
//  StudioEndPoint.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-29.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

public enum StudioAPIProvider {
	case fetchBrandAssets(id: String)
	case fetchNextBrandAssets(brandID: String, lastAssetID: Int)
	case delete(studioItemID: String)
	case uploadAsset(brandID: BrandID, studioAsset: Data)
}

extension StudioAPIProvider: EndPointType {
	var baseURL: URL {
		return BRXNDBaseURL.url
	}

	var path: String {
		switch self {
		case .fetchBrandAssets(let id):
			return "/api/v1/brands/\(id)s"
		case .fetchNextBrandAssets:
			return "/api/v1/load-next-media"
		case .delete(studioItemID: let id):
			return "/api/v1/media/\(id)"
		case .uploadAsset:
			return "api/v1/media"
		}
	}

	var httpMethod: HTTPMethod {
		switch self {
		case .fetchBrandAssets, .fetchNextBrandAssets:
			return .get
		case .delete:
			return .delete
		case .uploadAsset:
			return .post
		}
	}

	var task: HTTPTask {

		switch self {
		case .fetchBrandAssets, .delete:
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .none,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())

		case .fetchNextBrandAssets(let brandID, let lastAssetID):
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .urlEncoding,
												urlParameters: ["brand_id": "\(brandID)", "last_media_id": "\(lastAssetID)"],
												additionalHeaders: Current.getHeadersWithAccessToken())

		case .uploadAsset(let brandID, let assset):
			return .requestParametersAndHeaders(bodyParameters: ["id": "\(brandID)", "file": assset],
												bodyEncoding: .multiPartEncoding,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())
		}

	}

	var headers: HTTPHeaders? {
		return nil
	}
}
