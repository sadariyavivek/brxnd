//
//  ScheduleServiceType.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-29.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

enum ScheduleServiceError: Error {
	case emptyResponse
	case canNotPublishPost
	case notLoggedInSocialMedia
}

extension ScheduleServiceError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .emptyResponse:
			return "Empty response"
		case .canNotPublishPost:
			return "Can not publish post"
		case .notLoggedInSocialMedia:
			return "Please log-in in social media first"
		}
	}
}
protocol ScheduleServiceType {
	func showFeed(for pageid: String) -> Observable<Result<FBPostsScheduled, Error>>

	func publishScheduledPostNow(for postIdentifier: PostIdentifier)
		-> Single<Result<BRXNDCreateOrDeleteResponse, Error>>
}
