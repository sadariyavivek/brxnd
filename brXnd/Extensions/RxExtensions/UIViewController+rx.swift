//
//  UIViewController+rx.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

public enum AlertStyle {
	case close
}

extension UIViewController {
	func alert(type: AlertStyle, title: String, text: String?) -> Completable {
		switch type {
		case .close:
			return Completable.create { [weak self] completable in
				let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
				alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
					completable(.completed)
				}))
				self?.present(alertVC, animated: true, completion: nil)
				return Disposables.create {
					self?.dismiss(animated: true, completion: nil)
				}
			}
		}
	}
}
