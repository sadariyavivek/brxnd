//
//  LoginView.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol LoginView: BaseView where Self: UIViewController {
	var vm: LoginViewModel! { get set }
}
