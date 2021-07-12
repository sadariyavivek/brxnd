//
//  PostingModuleFactory.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-13.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol PostingModuleFactory {
	func makePostingModule(with dependency: MediaItem) -> (PostingView, PostingViewModelType)
}
