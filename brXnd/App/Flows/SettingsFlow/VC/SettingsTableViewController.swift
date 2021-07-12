//
//  SettingsTableViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Nuke

protocol SettingsView: BaseView {
	var viewModel: SettingsViewModel! { get set }
}
final class SettingsTableViewController: UITableViewController, BindableType, SettingsView {

	@IBOutlet weak var accountImageView: UIImageView!

	@IBOutlet weak var accountName: UILabel!
	@IBOutlet weak var accountEmail: UILabel!
	@IBOutlet weak var appVersion: UILabel!

	@IBOutlet weak var showAppTutorialButton: UIButton!
	@IBOutlet weak var socialMediaButton: UIButton!
	@IBOutlet weak var termsOfServiceButton: UIButton!
	@IBOutlet weak var privacyPolicyButton: UIButton!

	var viewModel: SettingsViewModel!
	
	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Settings"
		setupComponents()

		setupUI()
		bindViewModel()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		StoreKitHelper.tryShowStoreKit()
	}

	/// most of the UI is done in storyboard here
	private func setupUI() {
		showAppTutorialButton.tintColor = BRXNDColors.uglyPurple
	}

	internal func bindViewModel() {

		let this = self

		let input = viewModel
			.input

		let output = viewModel
			.output

		this
			.rx
			.methodInvoked(#selector(viewDidAppear(_:)))
			.map { _ in }
			.bind(to: input.viewDidAppearTrigger)
			.disposed(by: disposeBag)

		output
			.userAccountDetails
			.filter { $0 != nil }
			.drive(onNext: { [ weak self] response in

				guard let self = self else { return }

				self.accountName.text = response?.name
				self.accountEmail.text = response?.email

				guard let avatarString = response?.avatar,
					let avatarURL = URL(string: BRXNDBaseURL.url.absoluteString + avatarString) else { return }

				let req = ImageRequest(url: avatarURL, processors: [
					ImageProcessor.Resize(size: CGSize(width: 50, height: 50)),
					ImageProcessor.Circle()
				])
				Nuke.loadImage(with: req, into: self.accountImageView)
			})
			.disposed(by: disposeBag)

		termsOfServiceButton
			.rx
			.action = input.termsOfServiceAction

		privacyPolicyButton
			.rx
			.action = input.privacyPolicyAction

		showAppTutorialButton
			.rx
			.action = input.showTutorialAction

		socialMediaButton
			.rx
			.action = input.socialMediaAction

	}
	
	private func setupComponents() {
		var logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: nil)
		navigationItem.rightBarButtonItem = logOutButton
		appVersion.text = Bundle.appVersion + "(\(Bundle.appBuild))"

		logOutButton
			.rx
			.action = viewModel.input.logOutAction
	}

	@IBAction
	func onContactSupport(_ sender: UIButton) {
		if let emailUrl = URL(string: "mailto:\(Current.supportEmail)") {
			UIApplication.shared.open(emailUrl, options: [:], completionHandler: nil)
		}
	}
}
