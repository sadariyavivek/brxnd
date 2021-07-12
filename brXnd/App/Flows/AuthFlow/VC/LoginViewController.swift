//
//  LoginViewController.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import NVActivityIndicatorView

final class LoginViewController: UIViewController, LoginView, NVActivityIndicatorViewable {

    #if DEBUG
    deinit {
        print("LoginVC deinit \(String(describing: self))")
    }
    #endif

    var vm: LoginViewModel!

    @IBOutlet weak var viewpass: UIView!
    @IBOutlet weak var viewemail: UIView!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var signUpWithEmailButton: UIButton!
    @IBOutlet weak var signUpWithLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!

    private var allGradientLayers: [CAGradientLayer] = []
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupUI()
        setupComponents()

        let output = vm.transform(input: (email: userNameTextField.rx.text.orEmpty.asDriver(),
                                          password: passwordTextField.rx.text.orEmpty.asDriver(),
                                          signUpFacebookTap: facebookButton.rx.tap.asObservable(),
                                          signUpEmailTap: signUpWithEmailButton.rx.tap.asObservable(),
                                          signIn: loginButton.rx.tap.asObservable()))

        
        output.signInEnabled
            .drive(onNext: { [weak self] valid in
                self?.loginButton.isEnabled = valid
                self?.loginButton.alpha = valid  ? 1.0 : 0.7
            }).disposed(by: disposeBag)

        output.signedIn
            .drive(onNext: { [weak self] signedIn in
                if !signedIn { self?.alert()}
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAnimating()
    }

    // MARK: - Layout
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for layer in self.allGradientLayers {
            layer.frame = layer.superlayer?.frame ?? CGRect.zero
        }
    }

    private func setupComponents() {
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            }).disposed(by: disposeBag)

        view.addGestureRecognizer(tapBackground)
    }

    private func setupUI() {
        // background color
        let viewGradient = CAGradientLayer()
        //        viewGradient.colors = [UIColor(red: 0.969, green: 0.518, blue: 0.384, alpha: 1).cgColor /* #F78462 */, UIColor(red: 0.545, green: 0.106, blue: 0.549, alpha: 1).cgColor /* #8B1B8C */]

        viewGradient.colors = [
            BRXNDColors.LayerColors.blueBerry.cgColor,
            BRXNDColors.LayerColors.barbiePink.cgColor
        ]

        viewGradient.locations = [0, 1]
        viewGradient.startPoint = CGPoint(x: 0.311, y: 1.098)
        viewGradient.endPoint = CGPoint(x: 0.689, y: -0.098)
        viewGradient.frame = self.view.bounds
        self.view.layer.insertSublayer(viewGradient, at: 0)
        self.allGradientLayers.append(viewGradient)

        loginButton.layer.cornerRadius = 27
        loginButton.layer.masksToBounds = true

        userNameTextField.layer.cornerRadius = 27
        userNameTextField.layer.masksToBounds = true
        userNameTextField.textColor = BRXNDColors.black
        userNameTextField.placeholderColor = UIColor.black
        userNameTextField.addPadding()

        passwordTextField.layer.cornerRadius = 27
        passwordTextField.layer.masksToBounds = true
        passwordTextField.textColor = BRXNDColors.black
        passwordTextField.placeholderColor = UIColor.black
        passwordTextField.addPadding()

        companyLabel.textColor = UIColor.white
        companyLabel.isUserInteractionEnabled = false

        signUpWithLabel.textColor = UIColor.white

        facebookButton.tintColor = UIColor.white

        signUpWithEmailButton.tintColor = UIColor.white

    }

    private func logoAnimation() {}

    private func alert() {
        self.presentAlertWithTitle(title: "😔", message: "Something went wrong \nPlease try again", options: "Ok") { _ in }
    }
    private func animateLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.startAnimating(nil, message: "Loading...", messageFont: nil, type: .lineScale, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil, fadeInAnimation: nil)
        }
    }
}
