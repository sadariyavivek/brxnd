//
//  ScheduledViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-24.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Action
import RxFeedback
import RxSwiftExt
import RxDataSources

typealias PostSection = AnimatableSectionModel<PostPage, FeedData>

private enum ScheduleEvent {
	case refresh
	case reachedBottom
	case response([PostSection])
	//	case paginatedResponse
	case error(Error)
}

private struct ScheduleState {

	var isRefreshing: Bool

	var postSection: [PostSection]
	var error: Error?

	init() {
		self.isRefreshing = true
		self.postSection = []
		self.error = nil
	}
}

extension ScheduleState {
	var shouldRefresh: Bool? {
		return self.isRefreshing ? true : nil
	}
}

private extension ScheduleState {
	static func reduce(state: ScheduleState, command: ScheduleEvent) -> ScheduleState {
		var result = state
		switch command {

		//user actions
		case .refresh:
			result.isRefreshing = true
			result.error = nil
			return result

		//machine feedback
		case .response(let response):
			result.isRefreshing = false
			result.error = nil
			result.postSection = response
			return result
		case .error(let error):
			result.error = error
			result.postSection = []
			result.isRefreshing = false
			return result
		case .reachedBottom:
			#if DEBUG
			fatalError()
			#else
			return result
			#endif
		}
	}
}

protocol ScheduledViewModelInput {
	var loadMorePosts: PublishRelay<Bool> { get }
	var postSelectedAction: Action<FeedData, Void> { get }
	var logInSocialMediaAction: Action<Void, Void> { get }
	var viewDidAppearTrigger: PublishRelay<Void> { get }
	func refresh()
}

protocol ScheduledViewModelOutput {
	var postSections: Driver<[PostSection]>! { get }
	var isRefreshing: Driver<Bool> { get }
	var error: Driver<Error?> { get }
}

protocol ScheduledViewModelCoordinator: class {
	var onItemSelect: ((FeedData) -> Void)? { get set }
	var onLogInSocialMedia: (() -> Void)? { get set }
}

protocol ScheduledViewModelType {
	var input: ScheduledViewModelInput { get }
	var output: ScheduledViewModelOutput { get }
	var coordinator: ScheduledViewModelCoordinator { get }
}

final class ScheduledViewModel: ScheduledViewModelType,
	ScheduledViewModelInput,
	ScheduledViewModelOutput,
	ScheduledViewModelCoordinator {

	var input: ScheduledViewModelInput { return self }
	var output: ScheduledViewModelOutput { return self }
	var coordinator: ScheduledViewModelCoordinator { return self }

	// MARK: - Input

	var loadMorePosts: PublishRelay<Bool> = PublishRelay()
	var viewDidAppearTrigger: PublishRelay<Void> = PublishRelay<Void>()
	func refresh() { refreshProperty.accept(())}

	// MARK: - Output
	var postSections: Driver<[PostSection]>!
	var isRefreshing: Driver<Bool>
	var error: Driver<Error?>

	// MARK: - Coordinator output
	lazy var postSelectedAction: Action<FeedData, Void> = {
		return Action<FeedData, Void> { [unowned self] post in
			self.onItemSelect?(post)
			return Observable.just(())
		}
	}()

	lazy var logInSocialMediaAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onLogInSocialMedia?()
			return Observable.just(())
		}
	}()

	var onItemSelect: ((FeedData) -> Void)?
	var onLogInSocialMedia: (() -> Void)?

	// MARK: - Private
	private let disposeBag = DisposeBag()
	private let refreshProperty = PublishRelay<Void>()

	private let scheduleService: ScheduleServiceType
	private let postsService: PagesFeedServiceType & PostsFeedServiceType

	private let errorSubject: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
	private var postSectionSubject: BehaviorRelay<[PostSection]> = BehaviorRelay(value: [])

	init(postsService: PagesFeedServiceType & PostsFeedServiceType,
		 scheduleService: ScheduleServiceType) {

		self.scheduleService = scheduleService
		self.postsService = postsService

		let activityIndicator = RxActivityIndicator()

		self.isRefreshing = activityIndicator
			.asDriver()

		self.error = self.errorSubject
			.asDriver()

		self.postSections = self.postSectionSubject
			.asDriver()

		let bindSubjects: (Driver<ScheduleState>) -> Signal<ScheduleEvent> = bind(self) { [unowned self] this, state in

			let subscriptions = [
				state.map { $0.postSection }.drive(self.postSectionSubject),
				state.map { $0.error }.drive(self.errorSubject)
			]

			let events: [Signal<ScheduleEvent>] = [
				this.refreshProperty.asSignal().map { ScheduleEvent.refresh },
				this.loadMorePosts.asSignalEmptyError().skip(1).map { _ in ScheduleEvent.reachedBottom },
				this.viewDidAppearTrigger.asSignalEmptyError().skip(1).map { _ in ScheduleEvent.refresh }
			]

			return Bindings(subscriptions: subscriptions, events: events)
		}

		let refreshFeedbackLoop: (Driver<ScheduleState>) -> Signal<ScheduleEvent> =
			react(request: {$0.shouldRefresh}) { _ in

				if Current.getLoggedInState() == SocialMediaState.loggedInWeb {
					return Signal.just(ScheduleEvent.error(ScheduleServiceError.notLoggedInSocialMedia))
				}

				//1, getting pages
				let pages = postsService
					.fetchPages()
					.trackActivity(activityIndicator)
					.map { result -> [PostPage] in
						switch result {
						case .success(let value):
							return value
						case .failure(let error):
							throw error
						}
				}

				// TODO: - Fix the error ( sometimes .flatMapLatest cancels the networkCall )

				//2, getting all posts for each page
				let pagesAndSections = pages.flatMapLatest { [unowned self] postPage -> Observable<[(PostPage, [FeedData])]> in
					return Observable.zip(
						postPage.map { page -> Observable<(PostPage, [FeedData])> in
							let posts = self.scheduleService
								.showFeed(for: page.id)
								.trackActivity(activityIndicator)
								.map { result -> [FeedData] in
									switch result {
									case .success(let scheduled):
										return scheduled.scheduledPosts?.scheduledPosts?.data ?? []
									case .failure:
										return []
									}
							}
							let zipped = Observable.zip(Observable.just(page), posts)
							return zipped
						}
					)
				}
				.map { pagesAndPosts in
					return pagesAndPosts.map { PostSection(model: $0.0, items: $0.1) }
				}

				return pagesAndSections
					.map { response in ScheduleEvent.response(response) }
					.asSignal(onErrorJustReturn: ScheduleEvent.error(ScheduleServiceError.emptyResponse))

		}

		let feedbackLoops: [(Driver<ScheduleState>) -> Signal<ScheduleEvent>] = [
			bindSubjects,
			refreshFeedbackLoop
		]

		// MARK: - ViewModel State Machine
		let viewModelState = Driver.system(initialState: ScheduleState(),
										   reduce: ScheduleState.reduce, feedback: feedbackLoops)

		viewModelState
			.drive()
			.disposed(by: disposeBag)

	}

}
