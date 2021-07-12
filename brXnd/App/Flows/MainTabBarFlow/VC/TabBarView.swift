//
//  TabBarView.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol TabBarView: BaseView {
	var onItemDidLoad: ((UINavigationController) -> Void)? { get set }
	var onItemFlowSelect: ((UINavigationController) -> Void)? { get set }

	var onPostsFlowSelect: ((UINavigationController) -> Void)? { get set }
	var onScheduleFlowSelect:	((UINavigationController) -> Void)? { get set }
	var onSettingsFlowSelect: ((UINavigationController) -> Void)? { get set }
}
