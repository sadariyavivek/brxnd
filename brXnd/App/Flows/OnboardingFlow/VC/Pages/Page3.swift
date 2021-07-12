//
//  Page3.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-01-31.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class Page3ViewController: UIViewController {

	@IBOutlet weak var achieveLabel: UILabel!
	@IBOutlet weak var finishButton: UIButton!

	var onFinishTap: (() -> Void)?

	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		achieveLabel.textColor = BRXNDColors.darkBlueGrey
		achieveLabel.font = BRXNDFonts.sourceSansProsemiBold17

		finishButton.cornerRadius = 20.2
		finishButton.backgroundColor = BRXNDColors.darkBlueGrey
		finishButton.tintColor = BRXNDColors.white

		finishButton.translatesAutoresizingMaskIntoConstraints = false
		finishButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
		finishButton.widthAnchor.constraint(equalToConstant: 120).isActive = true

		finishButton
			.rx
			.tap
			.take(1)
			.subscribe(onNext: { [unowned self] in
				self.onFinishTap?()
			}).disposed(by: disposeBag)
	}
}
