//
//  UIImageExtensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-14.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension UIImage {
	func toData() -> Data {
		let imageData = self.jpegData(compressionQuality: 1)
		return imageData!
	}
	func base64EncodedString() -> String {
		let imageData = self.toData()
		let stringData = imageData.base64EncodedString(options: .endLineWithCarriageReturn)
		return stringData
	}
}

extension UIImage {
	func fixOrientation() -> UIImage {
		if self.imageOrientation == .up {
			return self
		} else {
			UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
			let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
			self.draw(in: rect)
			let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
			UIGraphicsEndImageContext()
			return normalizedImage
		}
	}
}
