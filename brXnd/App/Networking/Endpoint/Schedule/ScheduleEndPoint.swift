//
//  ScheduleEndPoint.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-18.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

public enum ScheduleAPIProvider {

	case scheduledFacebookPostFor(PageID)
	case publishScheduledPostNow(PostIdentifier)

	//	case retrievePaginatedScheduledPostsFor(PaginationTuple)
}

extension ScheduleAPIProvider: EndPointType {
	var baseURL: URL {
		let url = BRXNDBaseURL.url
		return url
	}

	var path: String {
		switch self {
		case .scheduledFacebookPostFor, .publishScheduledPostNow:
			return "/api/v1/facebook-scheduled-posts"
		}
	}

	var httpMethod: HTTPMethod {
		switch self {
		case .scheduledFacebookPostFor:
			return .get
		case .publishScheduledPostNow:
			return .post
		}
	}

	var task: HTTPTask {
		switch self {
		case .scheduledFacebookPostFor(let pageID):
			return .requestParametersAndHeaders(bodyParameters: nil,
												bodyEncoding: .urlEncoding,
												urlParameters: ["pageId": "\(pageID)"],
												additionalHeaders: Current.getHeadersWithAccessToken())
		case .publishScheduledPostNow(let identifier):
			return .requestParametersAndHeaders(bodyParameters: ["post_id": "\(identifier.1)", "page_id": "\(identifier.0)"],
												bodyEncoding: .jsonEncoding,
												urlParameters: nil,
												additionalHeaders: Current.getHeadersWithAccessToken())
		}
	}

	var headers: HTTPHeaders? {
		return nil
	}

}
