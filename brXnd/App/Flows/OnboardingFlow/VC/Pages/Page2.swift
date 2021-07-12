//
//  Page2.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-01-31.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class Page2ViewController: UIViewController {

	@IBOutlet weak var designLabel: UILabel!
	@IBOutlet weak var tutorialLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		designLabel.textColor = BRXNDColors.darkBlueGrey
		designLabel.font = BRXNDFonts.sourceSansProsemiBold17

		tutorialLabel.textColor = BRXNDColors.darkBlueGrey
		tutorialLabel.font = BRXNDFonts.sourceSansProsemiBold13
	}
}
