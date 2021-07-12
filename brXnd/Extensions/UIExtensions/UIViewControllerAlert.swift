//
//  UIViewControllerAlert.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-28.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension UIViewController {
	func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		for (index, option) in options.enumerated() {
			alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (_) in
				completion(index)
			}))
		}
		self.present(alertController, animated: true, completion: nil)
	}
}
