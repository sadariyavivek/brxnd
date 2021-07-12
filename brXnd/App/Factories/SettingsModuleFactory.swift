//
//  SettingsModuleFactory.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-18.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol SettingsModuleFactory {
	func makeSettingsModule() -> (SettingsView, SettingsViewModelType)
	func makeSettingsTerms(with data: String) -> SettingsTermsView
	func makeSocialMediaModule() -> SocialMediaSettingsTableViewController
}
