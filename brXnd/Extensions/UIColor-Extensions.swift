//
//  UIColor-Extensions.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-08.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

// swiftlint:disable all

//hex from UIColor
extension UIColor {
	var hexString: String {
		let colorRef = cgColor.components
		let r = colorRef?[0] ?? 0
		let g = colorRef?[1] ?? 0
		let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
		let a = cgColor.alpha

		var color = String(
			format: "#%02lX%02lX%02lX",
			lroundf(Float(r * 255)),
			lroundf(Float(g * 255)),
			lroundf(Float(b * 255))
		)

		if a < 1 {
			color += String(format: "%02lX", lroundf(Float(a)))
		}

		return color
	}
}

//UIColor from hex string
extension UIColor {
    func inverse () -> UIColor {
         var r:CGFloat = 0.0; var g:CGFloat = 0.0; var b:CGFloat = 0.0; var a:CGFloat = 0.0;
         if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
             return UIColor(red: 1.0-r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
         }
         return .black // Return a default colour
     }
    
	public convenience init?(hex: String) {
		let r, g, b, a: CGFloat

		if hex.hasPrefix("#") {
			let start = hex.index(hex.startIndex, offsetBy: 1)
			let hexColor = String(hex[start...])

			if hexColor.count == 8 {
				let scanner = Scanner(string: hexColor)
				var hexNumber: UInt64 = 0

				if scanner.scanHexInt64(&hexNumber) {
					r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
					g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
					b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
					a = CGFloat(hexNumber & 0x000000ff) / 255

					self.init(red: r, green: g, blue: b, alpha: a)
					return
				}
			}
		}
		return nil
	}
}
// swiftlint:enable all
