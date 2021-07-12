//
//  ScheduledView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-23.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol ScheduledView: BaseView  where Self: UIViewController {
	var viewModel: ScheduledViewModelType! { get set }
}
