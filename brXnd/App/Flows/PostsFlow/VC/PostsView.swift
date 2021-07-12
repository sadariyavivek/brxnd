//
//  PostsView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-28.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol PostsView: BaseView  where Self: UIViewController {
	var viewModel: PostsViewModelType! { get set }
}
