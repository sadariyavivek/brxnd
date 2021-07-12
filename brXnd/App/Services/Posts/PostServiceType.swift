//
//  PostServiceType.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-02.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

enum PostsServiceError: Error {
	case emptyResponse
	case notLoggedInSocialMedia

	case postingFailed

	case updateFailed(PostsFeed)
	case selectedFailed(PostsFeed)

	case deleteFailed

	case networkUnavaliable
}

extension PostsServiceError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .emptyResponse:
			return "Empty response"
		case .notLoggedInSocialMedia:
			return "Please log-in in social media first"
		case .updateFailed, .selectedFailed:
			return "Post update failed"
		case .deleteFailed:
			return "Failed to delete post"
		case .networkUnavaliable:
			return "Network unavailable"
		case .postingFailed:
			return "Failed to post"
		}
	}
}

protocol PostsFeedServiceType {

	func deletePost(identifier: PostIdentifier) -> Single<Result<String, Error>>

	func editPost(id: String) -> Observable<Void>

	func showFeed(for pageid: String) -> Observable<Result<FBPosts, Error>>
    func showFeedInsta() -> Observable<Result<InstaPosts, Error>>

	func getNextPosts(for pageID: String, cursor: String) -> Single<Result<FBPostsPaginated, Error>>

	func newPost(with post: NewPost) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>>
}

protocol PagesFeedServiceType {

	func fetchPages() -> Observable<Result<[PostPage], Error>>
}
