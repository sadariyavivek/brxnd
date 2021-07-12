//
//  UIViewControllerExtensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-04-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension UIViewController {
	public func setTitles(navigationTitle: String, tabBarTitle: String) {
		title = tabBarTitle
		navigationItem.title = navigationTitle
	}
}
