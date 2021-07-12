//
//  ScheduleService.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-29.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct ScheduleService: ScheduleServiceType {

	let scheduleAPI: ScheduledAPI

	init(scheduleAPI: ScheduledAPI = ScheduledAPI()) {
		self.scheduleAPI = scheduleAPI
	}

	func showFeed(for pageid: String) -> Observable<Result<FBPostsScheduled, Error>> {
		return Observable.deferred {
			self.scheduleAPI
				.rx
				.getScheduledPosts(for: pageid)
				.retry(1)
				.timeout(.seconds(10), scheduler: MainScheduler.instance)
		}
	}

	func publishScheduledPostNow(for postIdentifier: PostIdentifier) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
		return Single.deferred {
			self.scheduleAPI
				.rx
				.publishScheduledPostNow(for: postIdentifier)
				.timeout(.seconds(10), scheduler: MainScheduler.instance)
		}
	}

}
