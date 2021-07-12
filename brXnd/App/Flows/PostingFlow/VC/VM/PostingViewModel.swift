//
//  PostingViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-13.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Action
import RxFeedback

private enum PostingFormEvent {

	case receivedPostingPages([PostPage])
	case receivedPostText(String)

	case postingPageSelect(PostPage)
	case facebookSelect(Bool)

	case isPostScheduled(Bool)
	case scheduledDate(Date)

	case publishNow
	case publishResponse(BRXNDCreateOrDeleteResponse)

	case error(Error)
}

private struct PostingFormState {

	private var mediaItem: MediaItem

	var image: UIImage {
		return mediaItem.image
	}
	var isPublishButtonEnabled: Bool {
		return
			isFacebookSelected &&
				!pagesReceived.isEmpty &&
				error == nil &&
				!pagesSelectedForPosting.isEmpty &&
				!postText.isEmpty &&
				postText.count >= 1
	}

	var isFacebookSelected: Bool
	var isPostScheduled: Bool
	var scheduledDate: Date?
	var pagesSelectedForPosting: [PostPage]
	var pagesReceived: [PostPage] //facebook for now
	var postText: String

	var publishNow: Bool
	var publishNowResponse: BRXNDCreateOrDeleteResponse?

	var error: Error?

	init(mediaItem: MediaItem) {
		self.mediaItem = mediaItem
		self.isFacebookSelected = false
		self.isPostScheduled = false
		self.scheduledDate = nil
		self.pagesSelectedForPosting = []
		self.pagesReceived = []
		self.postText = ""
		self.publishNow = false
		self.publishNowResponse = nil
		self.error = nil
	}
}

extension PostingFormState {
	var shouldLoadPages: Bool? {
		return self.pagesReceived.isEmpty ? true : nil
	}
}

extension PostingFormState: Equatable {
	static func == (lhs: PostingFormState, rhs: PostingFormState) -> Bool {
		// should be enough
		return lhs.postText == rhs.postText && lhs.image == rhs.image
	}
}
extension PostingFormState {
	var shouldPublishNow: PostingFormState? {
		return self.publishNow ? self : nil
	}
}

private extension PostingFormState {
	static func reduce(state: PostingFormState,
					   command: PostingFormEvent) -> PostingFormState {
		var result = state
		switch command {

		//machine feedback
		case .receivedPostingPages(let pages):
			result.pagesReceived = pages
			result.error = nil

		case .error(let error):
			result.error = error
			result.publishNow = false
			return result

		case .publishResponse(let response):
			result.error = nil
			result.publishNowResponse = response
			result.publishNow = false
			return result

		// human actions
		case .facebookSelect(let selected):
			result.isFacebookSelected = selected
			return result

		case .postingPageSelect(let pageSelected):
			// if in the array already, remove it
			if result.pagesSelectedForPosting.contains(pageSelected) {
				result.pagesSelectedForPosting.removeAll(where: {$0 == pageSelected})
			} else {
				//otherwise add it
				result.pagesSelectedForPosting.append(pageSelected)
			}
			return result

		case .receivedPostText(let text):
			result.postText = text
			return result

		case .isPostScheduled(let scheduled):
			result.isPostScheduled = scheduled
			return result

		case .scheduledDate(let date):
			result.scheduledDate = date
			return result

		case .publishNow:
			result.publishNow = true
			return result
		}
		return result
	}
}

protocol PostingViewModelInput {
	// text for post
	var messageTextField: PublishRelay<String> { get }
	// which social media is enabled for posting ( facebook or instagram )
	var facebookSelected: PublishRelay<Bool> { get }

	// isScheduled, and the date for it
	var isPostScheduled: PublishRelay<Bool> { get }
	var scheduledDate: PublishRelay<Date> { get }

	// pages selected for posting
	var selectedPostPage: PublishRelay<PostPage> { get }

	// dismiss view
	var onCloseTapAction: Action<Void, Void> { get }
	// on publish
	var onPublishTapAction: Action<Void, Void> { get }
}

protocol PostingViewModelOutput {
	// isUpdating ( when posting )
	var isUpdating: Driver<Bool> { get }
	// response for post ( sucess or not )
	var isPublishButtonEnabled: Driver<Bool> { get }
	//post pages
	var postPages: Driver<[PostPage]> { get }
	// image
	var media: Driver<UIImage?> { get }
	// publishResponse
	var publishResponse: Driver<BRXNDCreateOrDeleteResponse?> { get }
	var error: Driver<Error?> { get }
}

protocol PostingViewModelCoordinator: class {
	var onFinish: (() -> Void)? { get set }
}

protocol PostingViewModelType {
	var input: PostingViewModelInput { get }
	var output: PostingViewModelOutput { get }
	var coordinator: PostingViewModelCoordinator { get }
}

final class PostingViewModel: PostingViewModelType,
	PostingViewModelInput,
	PostingViewModelOutput,
	PostingViewModelCoordinator {
	
	var input: PostingViewModelInput { return self }
	var output: PostingViewModelOutput { return self }
	var coordinator: PostingViewModelCoordinator { return self}
	
	// MARK: - Action
	lazy var onCloseTapAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onFinish?()
			return Observable.just(())
		}
	}()

	lazy var onPublishTapAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.publishNowSubject.accept(())
			return Observable.just(())
		}
	}()
	
	// MARK: - Input
	var selectedPostPage: PublishRelay<PostPage> = PublishRelay()
	var messageTextField: PublishRelay<String> = PublishRelay()
	var facebookSelected: PublishRelay<Bool> = PublishRelay()
	var isPostScheduled: PublishRelay<Bool> = PublishRelay()
	var scheduledDate: PublishRelay<Date> = PublishRelay()
	
	// MARK: - Output
	var isPublishButtonEnabled: Driver<Bool>
	var postPages: Driver<[PostPage]>
	var media: Driver<UIImage?>
	var isUpdating: Driver<Bool>
	var publishResponse: Driver<BRXNDCreateOrDeleteResponse?>
	var error: Driver<Error?>

	// MARK: - Coordinator
	var onFinish: (() -> Void)?
	
	// MARK: - Private
	private let disposeBag = DisposeBag()
	private let postsService: PagesFeedServiceType & PostsFeedServiceType

	private let publishNowSubject = PublishRelay<Void>()
	private let publishResponseSubject = BehaviorRelay<BRXNDCreateOrDeleteResponse?>(value: nil)
	private let isPublishButtonEnabledSubject: BehaviorRelay<Bool> = BehaviorRelay(value: false)
	private let mediaSubject: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
	private let pagesSubject: BehaviorRelay<[PostPage]> = BehaviorRelay(value: [])
	private let errorSubject: BehaviorRelay<Error?> = BehaviorRelay(value: nil)
	
	init(postsService: PagesFeedServiceType & PostsFeedServiceType,
		 mediaItem: MediaItem) {

		let activityIndicator = RxActivityIndicator()

		self.postsService = postsService

		self.isPublishButtonEnabled = isPublishButtonEnabledSubject
			.asDriver()

		self.postPages = pagesSubject
			.asDriver()

		self.media = mediaSubject
			.asDriver()

		self.isUpdating = activityIndicator
			.asDriver()

		self.publishResponse = publishResponseSubject
			.asDriver(onErrorJustReturn: nil)

		self.error = errorSubject
			.asDriver()

		let bindSubjects: (Driver<PostingFormState>) -> Signal<PostingFormEvent> = bind(self) { [unowned self] this, state in
			
			let subscriptions: [Disposable] = [
				state.map { $0.isPublishButtonEnabled }.drive(self.isPublishButtonEnabledSubject),
				state.map { $0.error }.drive(self.errorSubject),
				state.map { $0.pagesReceived }.drive(self.pagesSubject),
				state.map { $0.image }.drive(self.mediaSubject),
				state.map { $0.publishNowResponse }.drive(self.publishResponseSubject)
			]
			
			let events: [Signal<PostingFormEvent>] = [
				this.messageTextField.asSignalEmptyError().debounce(.milliseconds(300)).map { text in PostingFormEvent.receivedPostText(text)
				},
				this.facebookSelected.asSignalEmptyError().map { selected in PostingFormEvent.facebookSelect(selected)
				},
				this.isPostScheduled.asSignalEmptyError().map { scheduled in
					PostingFormEvent.isPostScheduled(scheduled)
				},
				this.scheduledDate.asSignalEmptyError().debounce(.milliseconds(300)).map { date in
					PostingFormEvent.scheduledDate(date)
				},
				this.selectedPostPage.asSignalEmptyError().map { postPageSelected in
					PostingFormEvent.postingPageSelect(postPageSelected)
				},
				this.publishNowSubject.asSignalEmptyError().debounce(.milliseconds(300)).map { _ in
					PostingFormEvent.publishNow
				}
			]
			
			return Bindings(subscriptions: subscriptions, events: events)
		}
		
		let loadPagesFeedbackLoop: (Driver<PostingFormState>) -> Signal<PostingFormEvent> =
			react(request: {$0.shouldLoadPages}) { _ in
				let pages = postsService
					.fetchPages()
					.map { result -> [PostPage] in
						switch result {
						case .success(let value):
							return value
						case .failure(let error):
							throw error
						}
				}
				return pages.map { response in PostingFormEvent.receivedPostingPages(response)}
					.asSignal(onErrorJustReturn: PostingFormEvent.error(PostsServiceError.emptyResponse))
		}

		let postFeedbackLoop: (Driver<PostingFormState>) -> Signal<PostingFormEvent> =
			react(request: {$0.shouldPublishNow}) { state in

				/// only one asset per upload
				let uploadMedia: [UploadMedia] = {
					switch mediaItem.mediaModifiers {
					case .isEdited:
						return [UploadMedia(type: "jpeg", url: mediaItem.assetModel?.newImage)]
					case .isOriginal:
						return [UploadMedia(type: "jpeg", url: mediaItem.assetModel?.url)]
					}
				}()

				let isoDateFormatter = ISO8601DateFormatter()

				let posts = state.pagesSelectedForPosting.map {
					NewPost(facebookPageID: $0.id,
							message: state.postText,
							media: uploadMedia,
							scheduled: state.isPostScheduled,
							scheduledPublishTime:
						String("\(isoDateFormatter.string(from: state.scheduledDate ?? Date()))"))
				}

				let networkCalls = Observable.zip(
					posts.compactMap { newPost -> Observable<BRXNDCreateOrDeleteResponse?> in
						return postsService
							.newPost(with: newPost)
							.trackActivity(activityIndicator)
							.map { result -> BRXNDCreateOrDeleteResponse in
								switch result {
								case .success(let response):
									return response
								case .failure(let error):
									throw error
								}
						}
					}
				)
					.compactMap { $0 }

				let result = networkCalls
					.map { response in response.compactMap { $0 }.first }
					.compactMap { $0 }

				return result.map { response in PostingFormEvent.publishResponse(response)}
					.asSignal(onErrorJustReturn: PostingFormEvent.error(PostsServiceError.postingFailed))

		}

		let feedBackLoops: [(Driver<PostingFormState>) -> Signal<PostingFormEvent>] = [
			bindSubjects,
			loadPagesFeedbackLoop,
			postFeedbackLoop
		]
		
		let viewModelState = Driver.system(initialState: PostingFormState(mediaItem: mediaItem),
										   reduce: PostingFormState.reduce,
										   feedback: feedBackLoops)
		
		viewModelState
			//			.debug("🔳 Posting state:", trimOutput: false)
			.drive()
			.disposed(by: disposeBag)
		
	}

}
