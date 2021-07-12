//
//  AuthModuleFactory.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol AuthModuleFactory {
	func makeLoginModule() -> (LoginView, LoginViewModel)
	func makeSignUpModule() -> (SignUpView, SignUpViewModel)
	func makeTermsModule() -> TermsView
}
