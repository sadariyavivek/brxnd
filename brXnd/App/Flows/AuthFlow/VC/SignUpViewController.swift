//
//  SignUpViewController.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import NVActivityIndicatorView

final class SignUpViewController: UIViewController, SignUpView, NVActivityIndicatorViewable {

	#if DEBUG
	deinit {
		print("SignUpVC deinit \(String(describing: self))")
	}
	#endif

	var vm: SignUpViewModel!

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var passwordRepeatedTextField: UITextField!

	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var termsConditionsButton: UIButton!

	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

        vm = SignUpViewModel()
		let output = vm.transform(input: (email:emailTextField.rx.text.orEmpty.asDriver(),
        password: passwordTextField.rx.text.orEmpty.asDriver(),
        repeatedPassword: passwordRepeatedTextField.rx.text.orEmpty.asDriver(),
        loginTap: signUpButton.rx.tap.asObservable(),
        termsTap: termsConditionsButton.rx.tap.asObservable()))

		output.signupEnabled
			.drive(onNext: { [weak self] valid in
				self?.signUpButton.isEnabled = valid
				self?.signUpButton.alpha = valid ? 1.0 : 0.7
			}).disposed(by: disposeBag)

		output.signedIn
			.drive(onNext: { [weak self] signedIn in
				if !signedIn {self?.errorAlert()}
			}).disposed(by: disposeBag)

		output.signingIn
			.drive(onNext: { [weak self] signingIn in
				if signingIn {self?.animateLoading()} else {self?.stopAnimating()}
			}).disposed(by: disposeBag)

		//debug
		#if DEBUG
		output.validatedEmail
			.drive(onNext: { result in
				print("Validated email: \(result)")
			}).disposed(by: disposeBag)

		output.validatedPassword
			.drive(onNext: { result in
				print("Validated password: \(result)")
			}).disposed(by: disposeBag)
		#endif

		let tapBackground = UITapGestureRecognizer()
		view.addGestureRecognizer(tapBackground)

		tapBackground.rx.event
			.subscribe(onNext: { [weak self] _ in
				self?.view.endEditing(true)
			}).disposed(by: disposeBag)
	}

    @IBAction func actSignUp(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    // MARK: - Status Bar
	override public var prefersStatusBarHidden: Bool {
		return false
	}
	override public var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: true)

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification),
											   name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification),
											   name: UIResponder.keyboardWillHideNotification, object: nil)

	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
		self.stopAnimating()
	}

	//	override func viewDidDisappear(_ animated: Bool) {
	//		super.viewDidDisappear(animated)
	//
	//	}

	@objc func keyboardWillShowNotification(notification: NSNotification) {
		UIView.animate(withDuration: 0.3) { [weak self] in
			self?.navigationItem.leftBarButtonItem?.customView?.alpha = 0
		}
	}

	@objc func keyboardWillHideNotification(notification: NSNotification) {
		UIView.animate(withDuration: 0.3) { [weak self] in
			self?.navigationItem.leftBarButtonItem?.customView?.alpha = 1
		}
	}

	private func errorAlert() {
		presentAlertWithTitle(title: "Oops,☹️", message: "Something went wrong, please try again", options: "Ok", completion: {_ in })
	}

	private func animateLoading() {
		DispatchQueue.main.async { [weak self] in
			guard let sSelf = self else { return }
			sSelf.startAnimating(nil, message: "Registering...", messageFont: nil, type: .lineScale, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil, fadeInAnimation: nil)
		}
	}
}
