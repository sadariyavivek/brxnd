//
//  BindableType.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-02.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol BindableType {

	associatedtype ViewModelType
	var viewModel: ViewModelType! {get set}
	func bindViewModel()

}

extension BindableType where Self: UIViewController {
	mutating func bindViewModel(to model: Self.ViewModelType) {
		viewModel = model
		loadViewIfNeeded()
		bindViewModel()
	}
}
