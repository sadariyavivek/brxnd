//
//  PostsFeedService.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-02.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct PostsFeedService: PostsFeedServiceType, PagesFeedServiceType {

	let postsFeedAPI: PostsAPI
	let pagesAPI: PagesAPI
    

	init(postsAPI: PostsAPI = PostsAPI(), pagesAPI: PagesAPI = PagesAPI()) {
		self.postsFeedAPI = postsAPI
		self.pagesAPI = pagesAPI
	}

    
	// MARK: - Pages

	func fetchPages() -> Observable<Result<[PostPage], Error>> {
		return Observable.deferred {
			self.pagesAPI
				.rx
				.getPages()
				.retry(1)
				.timeout(.seconds(10), scheduler: MainScheduler.instance)
		}
	}

	// MARK: - Posts
	func showFeed(for pageid: String) -> Observable<Result<FBPosts, Error>> {
		return Observable.deferred {
			self.postsFeedAPI
				.rx
				.getPosts(for: pageid)
				.retry(1)
				.timeout(.seconds(10), scheduler: MainScheduler.instance)
		}
	}
    
    func showFeedInsta() -> Observable<Result<InstaPosts, Error>> {
        return Observable.deferred {
            self.postsFeedAPI
                .rx
                .getPostsInsta()
                .retry(1)
                .timeout(.seconds(10), scheduler: MainScheduler.instance)
        }
    }
    

	func getNextPosts(for pageID: String, cursor: String) -> Single<Result<FBPostsPaginated, Error>> {
		return Single.deferred {
			self.postsFeedAPI
				.rx
				.getNextPosts(for: pageID, cursor: cursor)
				.retry(1)
				.timeout(.seconds(10), scheduler: MainScheduler.instance)
		}
	}

	func deletePost(identifier: PostIdentifier) -> Single<Result<String, Error>> {
		return Single.deferred {
			self.postsFeedAPI
				.rx
				.deletePost(for: identifier)
				.retry(1)
				.timeout(.seconds(10), scheduler: MainScheduler.instance)
		}
	}

	func newPost(with post: NewPost) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
		return Single.deferred {
			self.postsFeedAPI
				.rx
				.newPost(with: post)
				.timeout(.seconds(10), scheduler: MainScheduler.instance)
		}
	}

	func editPost(id: String) -> Observable<Void> {
		fatalError()
	}
}
