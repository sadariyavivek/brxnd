//
//  BrandEndPoint.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-25.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

public typealias BrandID = Int

public enum BrandAPIProvider {

	case fetchAllBrands
    case fetchFBpages
	case createNewBrand(name: String, description: String, color: String, isDraft: Bool, brandLogo: Data)
	case deleteBrand(id: BrandID)

	case updateBrand
	case updateBrandLogo
}

extension BrandAPIProvider: EndPointType {

	var baseURL: URL {
		let url = BRXNDBaseURL.url
		return url
	}

	var path: String {
		switch self {
		case .fetchAllBrands, .createNewBrand:
			return "/api/v1/brands"
		case .deleteBrand(let id):
			return "/api/v1/brands/\(id)"
        case .fetchFBpages:
            return "/api/v1/facebook-pages"
		default:
			fatalError("Not implemented")
		}
	}

	var httpMethod: HTTPMethod {
		switch self {
        case .fetchAllBrands, .fetchFBpages:
			return .get
		case .createNewBrand:
			return .post
		case .deleteBrand:
			return .delete
		default:
			fatalError("Not implemented")
		}
	}

	var task: HTTPTask {

		switch self {
		case .fetchAllBrands:
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .none,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())

		case .createNewBrand(let name, let description, let color, let isDraft, let brandLogo):
			return .requestParametersAndHeaders(bodyParameters: ["name": "\(name)",
				"description": "\(description)",
				"color": "\(color)",
				"draft": "\(isDraft ? "1" : "0")",
				"file": brandLogo],
												bodyEncoding: .multiPartEncoding,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())

		case .deleteBrand:
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .none,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())
        
        case .fetchFBpages:
        return .requestParametersAndHeaders(bodyParameters: nil,
                                            bodyEncoding: .none,
                                            urlParameters: ["large_pic": "true"],
                                            additionalHeaders: Current.getHeadersWithAccessToken())
		default:
			fatalError("Not implemented")
		}
	}
	var headers: HTTPHeaders? {
		return nil
	}
}
