//
//  UITextFieldExtensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-18.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension UITextField {
	@IBInspectable var placeholderColor: UIColor {
		get {
			return self.attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .lightText
		}
		set {
			self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [.foregroundColor: newValue])
		}
	}
}

extension UITextField {
	func addPadding(width: CGFloat = 20) {
		let paddingView	 	= UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height))
		self.leftView 		= paddingView
		self.leftViewMode 	= UITextField.ViewMode.always
	}
}
