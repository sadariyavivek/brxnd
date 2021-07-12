//
//  PostsViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-28.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Action
import RxFeedback
import RxSwiftExt

private enum PostsEvent {
    case refresh
    case reachedBottom
    case selectNewPage(Int?)

    case initial([PostPage])
    case response(FBPosts?, [PostPage])
    case paginatedResponse(FBPostsPaginated?)
    case error(Error)
}

private struct PostsState {

    var isRefreshing: Bool
    var isLoadingNext: Bool
    var shouldLoadFirstPage: trigger

    var currentSelectedPage: Int?
    var posts: FBPosts?
    var pages: [PostPage]
    var pagingTuple: (String, String)?     /// after, before
    var error: Error?

    init(currentSelectedPage: Int? = nil) {

        self.isRefreshing = true
        self.isLoadingNext = false
        self.shouldLoadFirstPage = 0

        self.currentSelectedPage = currentSelectedPage
        self.posts = nil
        self.pages = []
        self.pagingTuple = nil
        self.error = nil

    }
}

private struct LoadNext: Equatable {
    var cursorAfter: String
    var pageID: String
}

private extension PostsState {
    var shouldRefresh: Int? {
        return self.isRefreshing ? self.currentSelectedPage : nil
    }
    var shouldLoadNext: LoadNext? {
        if let after = self.pagingTuple?.0, let currentPageID = self.currentSelectedPage {
            return self.isLoadingNext ? LoadNext(cursorAfter: after, pageID: String(currentPageID)) : nil
        } else {
            return nil
        }
    }
}

private extension PostsState {
    static func reduce(state: PostsState, command: PostsEvent) -> PostsState {
        var result = state
        switch command {

        //user actions
        case .refresh:
            if result.currentSelectedPage == nil {
                /// trigger the first firstPageFeedbackLoop, as just setting it to "true" does not trigger a loop
                result.shouldLoadFirstPage += 1
            } else {
                result.isRefreshing = true
            }
            result.isLoadingNext = false
            result.error = nil
            result.pagingTuple = nil
            return result

        case .reachedBottom:
            result.isLoadingNext = true
            return result

        case .selectNewPage(let id):
            result.isRefreshing = true
            result.currentSelectedPage = id
            result.pagingTuple = nil
            result.error = nil
            result.isLoadingNext = false
            return result

        //machine feedback
        case .initial(let pages):
            result.currentSelectedPage = Int(pages.first?.id ?? "")
            result.pages = pages
            result.error = nil
            result.isRefreshing = true
            result.isLoadingNext = false
            return result
        case .response(let posts, let pages):
            result.posts = posts
            result.pages = pages
            result.isRefreshing = false
            result.isLoadingNext = false
            result.error = nil
            result.pagingTuple = (posts?.posts.feed?.paging?.cursors?.after ?? "",
                                  posts?.posts.feed?.paging?.cursors?.before ?? "")
            return result

        case .paginatedResponse(let paginated):
            result.isLoadingNext = false
            result.isRefreshing = false
            result.error = nil

            if  let oldPosts = result.posts?.posts.feed?.data,
                let newPosts = paginated?.posts.data {

                let newAndOld = [oldPosts, newPosts].reduce([], +)

                result.posts?.posts.feed?.data = newAndOld
                result.pagingTuple = (paginated?.posts.paging?.cursors?.after ?? "",
                                      paginated?.posts.paging?.cursors?.before ?? "")

            } else {
                #if DEBUG
                fatalError("Can't retrieve paginated posts")
                #endif
            }
            return result

        case .error(let error):
            result.error = error

            result.pages = []
            result.posts = nil

            result.isLoadingNext = false
            result.isRefreshing = false
            result.pagingTuple = nil

            #if DEBUG
            print("\(self) received error: \(error)")
            #endif

            return result
        }
    }
}

protocol PostsViewModelCoordinator: class {
    var onItemSelect: ((FeedData) -> Void)? { get set }
    var onLogInSocialMedia: (() -> Void)? { get set }
}

protocol PostsViewModelInput {
    var viewDidAppearTrigger: PublishRelay<Void> { get }
    var pageSelected: PublishRelay<String> { get }
    var loadMorePosts: PublishRelay<Bool> { get }

    var logInSocialMediaAction: Action<Void, Void> { get }
    var postSelectedAction: Action<FeedData, Void> { get }

    func refresh()
}

protocol PostsViewModelOutput {

    var posts: Driver<FBPosts?> { get }
    var pages: Driver<[PostPage]> { get }

    var isRefreshing: Driver<Bool> { get }
    var error: Driver<Error?> { get }
}

protocol PostsViewModelType {
    var input: PostsViewModelInput { get }
    var output: PostsViewModelOutput { get }
    var coordinator: PostsViewModelCoordinator { get }
}

final class PostsViewModel: PostsViewModelType,
    PostsViewModelInput,
    PostsViewModelOutput,
    PostsViewModelCoordinator {

    var input: PostsViewModelInput { return self }
    var output: PostsViewModelOutput { return self }
    var coordinator: PostsViewModelCoordinator { return self }

    // MARK: - Input
    var pageSelected = PublishRelay<String>()
    var loadMorePosts = PublishRelay<Bool>()
    var viewDidAppearTrigger: PublishRelay<Void> = PublishRelay<Void>()

    // MARK: - Output
    var posts: Driver<FBPosts?>
    var pages: Driver<[PostPage]>

    var isRefreshing: Driver<Bool>
    var error: Driver<Error?>

    // MARK: - Coordinator output
    var onItemSelect: ((FeedData) -> Void)?
    var onLogInSocialMedia: (() -> Void)?

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

    // MARK: - Private
    private let disposeBag = DisposeBag()
    private let refreshProperty = PublishRelay<Void>()
    private let postsService: PagesFeedServiceType & PostsFeedServiceType

    private let pagesSubject: BehaviorRelay<[PostPage]> = BehaviorRelay(value: [])
    private let postsSubject: BehaviorRelay<FBPosts?> = BehaviorRelay(value: nil)
    private let errorSubject: BehaviorRelay<Error?> = BehaviorRelay(value: nil)

    func refresh() {refreshProperty.accept(())}

    init(postsService: PagesFeedServiceType & PostsFeedServiceType) {

        let activityIndicator = RxActivityIndicator()

        self.isRefreshing = activityIndicator
            .asDriver()

        self.postsService = postsService

        self.posts = self.postsSubject
            .asDriver()

        self.pages = self.pagesSubject
            .asDriver()

        self.error = self.errorSubject
            .asDriver()

        let bindSubjects: (Driver<PostsState>) -> Signal<PostsEvent> = bind(self) { [unowned self] this, state in

            let subscriptions = [
                state.map { $0.posts }.drive(self.postsSubject),
                state.map { $0.pages }.drive(self.pagesSubject),
                state.map { $0.error }.drive(self.errorSubject)
            ]

            let events: [Signal<PostsEvent>] = [
                this.refreshProperty.asSignal().map { PostsEvent.refresh },
                this.pageSelected.asSignalEmptyError().map { id in PostsEvent.selectNewPage(Int(id))},
                this.loadMorePosts.asSignalEmptyError().skip(1).map { _ in PostsEvent.reachedBottom },
                this.viewDidAppearTrigger.asSignalEmptyError().skip(1).map { _ in PostsEvent.refresh }
            ]

            return Bindings(subscriptions: subscriptions, events: events)
        }

        let firstPageFeedbackLoop: (Driver<PostsState>) -> Signal<PostsEvent> =
            react(request: { $0.shouldLoadFirstPage }, effects: { _ in

                if Current.getLoggedInState() == SocialMediaState.loggedInWeb {
                    return Signal.just(PostsEvent.error(PostsServiceError.notLoggedInSocialMedia))
                }

                return postsService
                    .fetchPages()
                    .trackActivity(activityIndicator)
                    .map { result in
                        switch result {
                        case .success(let value):
                            return value
                        case .failure(let error):
                            throw error
                        }
                }
                .map { response in PostsEvent.initial(response)}
                .asSignal(onErrorJustReturn: PostsEvent.error(PostsServiceError.emptyResponse))
            })

        let refreshFeedbackLoop: (Driver<PostsState>) -> Signal<PostsEvent> =
            react(request: { $0.shouldRefresh }, effects: { id in

                if Current.getLoggedInState() == SocialMediaState.loggedInWeb {
                    return Signal.just(PostsEvent.error(PostsServiceError.notLoggedInSocialMedia))
                }

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

                let posts = postsService
                    .showFeed(for: String(id))
                    .trackActivity(activityIndicator)
                    .map { result -> FBPosts? in
                        switch result {
                        case .success(let value):
                            return value
                        case .failure:
                            return nil
                        }
                }
                return Observable.zip(posts, pages)
                    .map { posts, pages in PostsEvent.response(posts, pages)}
                    .asSignal(onErrorJustReturn: PostsEvent.error(PostsServiceError.emptyResponse))
            })

        let postsPaginationFeedbackLoop: (Driver<PostsState>) -> Signal<PostsEvent> =
            react(request: { $0.shouldLoadNext }, effects: { next -> Signal<PostsEvent> in
                return postsService
                    .getNextPosts(for: next.pageID, cursor: next.cursorAfter)
                    .map(extractSuccess)
                    .asObservable()
                    .asSignal(onErrorJustReturn: nil)
                    ///if posts array isEmpty, filter it out, if data is not empty, pass it thorough
                    .filter { !($0?.posts.data.isEmpty ?? true)}
                    .map { response in PostsEvent.paginatedResponse(response)}
            })

        let feedbackLoops: [(Driver<PostsState>) -> Signal<PostsEvent>] = [
            bindSubjects,
            firstPageFeedbackLoop,
            refreshFeedbackLoop,
            postsPaginationFeedbackLoop
        ]

        // MARK: - ViewModel State Machine
        let viewModelState = Driver.system(initialState: PostsState(),
                                           reduce: PostsState.reduce,
                                           feedback: feedbackLoops)
        
        viewModelState
            .drive()
            .disposed(by: disposeBag)

    }
}
