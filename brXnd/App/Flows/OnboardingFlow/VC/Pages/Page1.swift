//
//  Page1.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-01-31.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class Page1ViewController: UIViewController {

	@IBOutlet weak var lookLabel: UILabel!
	@IBOutlet weak var tutorialLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		lookLabel.textColor = BRXNDColors.darkBlueGrey
		lookLabel.font = BRXNDFonts.sourceSansProsemiBold17

		tutorialLabel.textColor = BRXNDColors.darkBlueGrey
		tutorialLabel.font = BRXNDFonts.sourceSansProsemiBold13
		
	}
}
