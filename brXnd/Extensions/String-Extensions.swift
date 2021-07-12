//
//  StringExtensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-22.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension String {
	func isValidEmail() -> Bool {
		do {
			let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .caseInsensitive)
			return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: self.count)) != nil
		} catch {
			return false
		}
	}
}
//used for converting emojis to images
extension String {
	func image() -> UIImage? {
		let size = CGSize(width: 40, height: 40)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		UIColor.white.set()
		let rect = CGRect(origin: .zero, size: size)
		UIRectFill(CGRect(origin: .zero, size: size))
		(self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
}
