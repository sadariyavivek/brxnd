//
//  SupportViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol SettingsTermsView: BaseView {}

final class SupportViewController: UIViewController, SettingsTermsView {
	
	var textToPresent: String!

	@IBOutlet weak var textView: UITextView!

	override func viewDidLoad() {
        super.viewDidLoad()
		textView.text = textToPresent
    }

}
