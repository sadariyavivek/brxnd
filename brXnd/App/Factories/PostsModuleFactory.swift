//
//  PostsModuleFactory.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-28.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol PostsModuleFactory {
	func makePostsModule() -> (PostsView, PostsViewModelType)
	func makePostEditModule(with post: FeedData) -> (PostEditView, PostsEditViewModelType)
	func makeScheduledPostsModule() -> (ScheduledView, ScheduledViewModelType)
}
