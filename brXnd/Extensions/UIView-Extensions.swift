//
//  UIView-Extensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-14.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension UIView {
	@discardableResult
	func add<T: UIView>(_ subview: T, then applyClosure: (T) -> Void) -> T {
		self.addSubview(subview)
		applyClosure(subview)
		return subview
	}
}
