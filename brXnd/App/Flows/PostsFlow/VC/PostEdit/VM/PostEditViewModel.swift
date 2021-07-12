//
//  PostEditViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-23.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Action

protocol PostsEditViewModelInput {

	var onDeleteTapSubject: PublishSubject<()> { get }
	var onPublishTapSubject: PublishSubject<()> { get }

	var onDoneTapAction: Action<Void, Void> { get }
}

protocol PostsEditViewModelOutput {
	var postData: FeedData { get }
	var isLoading: Driver<Bool> { get }
	var deleteResponse: Driver<Result<String, Error>>! { get }
	var publishResponse: Driver<Result<BRXNDCreateOrDeleteResponse, Error>>! { get }
}

protocol PostsEditViewModelCoordinator: class {
	var onDoneTap: (() -> Void)? { get set }
	var onExitTap: (() -> Void)? { get set }
}

protocol PostsEditViewModelType {
	var input: PostsEditViewModelInput { get }
	var output: PostsEditViewModelOutput { get }
	var coordinator: PostsEditViewModelCoordinator { get }
}

final class PostsEditViewModel: PostsEditViewModelType,
	PostsEditViewModelInput,
	PostsEditViewModelOutput,
	PostsEditViewModelCoordinator {

	var input: PostsEditViewModelInput { return self }
	var output: PostsEditViewModelOutput { return self }
	var coordinator: PostsEditViewModelCoordinator { return self }

	// MARK: - Input
	var onDeleteTapSubject: PublishSubject<Void> = PublishSubject()
	var onPublishTapSubject: PublishSubject<Void> = PublishSubject()

	// MARK: - Action

	lazy var onDoneTapAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onDoneTap?()
			return Observable.just(())
		}
	}()

	// MARK: - Output
	let postData: FeedData
	var isLoading: Driver<Bool>
	var deleteResponse: Driver<Result<String, Error>>!
	var publishResponse: Driver<Result<BRXNDCreateOrDeleteResponse, Error>>!

	// MARK: - Coordinator
	var onDoneTap: (() -> Void)?
	var onExitTap: (() -> Void)?

	private let postsService: PostsFeedServiceType
	private let scheduleService: ScheduleServiceType
	
	init(postsService: PostsFeedServiceType,
		 scheduleService: ScheduleServiceType,
		 postData: FeedData) {

		self.postData = postData
		self.postsService = postsService
		self.scheduleService = scheduleService

		let loadingIndicator = RxActivityIndicator()

		self.isLoading = loadingIndicator
			.asDriver()
			.startWith(false)

		self.deleteResponse = self.onDeleteTapSubject.flatMap { _ -> Single<Result<String, Error>> in
			return postsService
				.deletePost(identifier: (postData.from.id, postData.id))
				.asObservable()
				.trackActivity(loadingIndicator)
				.asSingle()
		}
		.asDriver(onErrorJustReturn: Result.failure(PostsServiceError.deleteFailed))
		.do(onNext: { [unowned self] _ in
			DispatchQueue.main.async {
				self.onExitTap?()
			}
		})

		self.publishResponse = self.onPublishTapSubject.flatMap { _ -> Single<Result<BRXNDCreateOrDeleteResponse, Error>> in
			return scheduleService
				.publishScheduledPostNow(for: (postData.from.id, postData.id))
				.asObservable()
				.trackActivity(loadingIndicator)
				.asSingle()
		}
		.asDriver(onErrorJustReturn: Result.failure(ScheduleServiceError.canNotPublishPost))
		.do(onNext: { [unowned self] _ in
			DispatchQueue.main.async {
				self.onExitTap?()
			}
		})
	}
}
