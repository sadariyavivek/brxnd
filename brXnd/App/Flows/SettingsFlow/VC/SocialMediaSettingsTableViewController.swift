//
//  SocialMediaSettingsTableViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-07.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import FBSDKLoginKit

final class SocialMediaSettingsTableViewController: UITableViewController {

	@IBOutlet weak var facebookButton: UIButton!

	private let facebookLoginManager = FacebookLoginManager.shared

	override func viewDidLoad() {
		super.viewDidLoad()
		fetchTokenStatus()
	}

	@IBAction func onTapFacebookButton(_ sender: UIButton) {
		if AccessToken.current == nil {
			facebookLoginManager.logIn { [weak self] result in
				switch result {
				case .success:
					DispatchQueue.main.async {
						self?.presentAlertWithTitle(title: "", message: "Logged in", options: "Ok",
													completion: { _ in })
						self?.fetchTokenStatus()
					}
				case .failure(let error):
					#if DEBUG
					print("Error: \(error)")
					#endif
				}
			}
		}
	}

	private func fetchTokenStatus() {
		if AccessToken.current != nil {
			facebookButton.setTitle("Logged in", for: .normal)
			facebookButton.isEnabled = false
		} else {
			facebookButton.setTitle("Log in facebook", for: .normal)
		}
	}

	//	@IBAction func onTapFacebookButton(_ sender: UIButton) {
	//		if AccessToken.current == nil {
	//			facebookLoginManager.logIn { [weak self] result in
	//				switch result {
	//				case .success:
	//					DispatchQueue.main.async {
	//						self?.presentAlertWithTitle(title: "", message: "Logged in", options: "Ok",
	//													completion: { _ in })
	//					}
	//				case .failure: return
	//				}
	//			}
	//		} else {
	//			facebookLoginManager.logOut()
	//			DispatchQueue.main.async {
	//				self.presentAlertWithTitle(title: "", message: "Logged out", options: "Ok",
	//										   completion: { _ in })
	//			}
	//		}
	//		fetchTokenStatus()
	//	}
	
	//	private func fetchTokenStatus() {
	//		if AccessToken.current != nil {
	//			facebookButton.setTitle("Unlink facebook account", for: .normal)
	//		} else {
	//			facebookButton.setTitle("Log in facebook", for: .normal)
	//		}
	//	}
}
