//
//  PostEditView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-23.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol PostEditView: BaseView {
	var isPublishNowButtonAvailable: Bool { get set }
	var viewModel: PostsEditViewModelType! { get set }
}
