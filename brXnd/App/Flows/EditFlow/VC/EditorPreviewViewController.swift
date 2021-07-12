//
//  EditorPreviewViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-05-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import UIImageColors
import RxSwiftExt

protocol EditorPreviewView: BaseView {
	var viewModel: EditorPreviewViewModelType! { get set }
}

final class EditorPreviewViewController: UIViewController, EditorPreviewView, BindableType {
	
	var viewModel: EditorPreviewViewModelType!
	
	// MARK: - Private
	private let disposeBag = DisposeBag()
	private let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
	
	@IBOutlet weak var libraryItemPreview: UIImageView!
	@IBOutlet weak var editButton: UIBarButtonItem!
	@IBOutlet weak var exportButton: UIBarButtonItem!
	@IBOutlet weak var createPostButton: UIBarButtonItem!
	@IBOutlet weak var playVideoIcon: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupComponents()
		bindViewModel()
		setupUI()

		///disable the interactive dismissal of presented view controller in iOS 13
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		} else {
			//
		}
	}
	
	internal func bindViewModel() {
		let output = viewModel
			.output
		
		let input = viewModel
			.input
		
		editButton
			.rx
			.action = input.onEditActionTap
		
		output
			.thumbnailImageFromStudioView
			.drive(libraryItemPreview.rx.image)
			.disposed(by: disposeBag)
		
		output
			.isLoading
			.not()
			.do(onNext: { [weak self] in
				self?.editButton.tintColor =
					$0 ? UIColor.black : UIColor.black.withAlphaComponent(0.5)
			})
			.drive(editButton.rx.isEnabled)
			.disposed(by: disposeBag)
		
		output
			.isLoading
			.drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
			.disposed(by: disposeBag)
		
		output
			.isLoading
			.drive(loadingIndicator.rx.isAnimating)
			.disposed(by: disposeBag)
		
		output
			.onLoadingEditorDataError?
			.drive(onNext: { [weak self] error in
				self?.presentAlertWithTitle(title: "Error loading editor data",
											message: "\(error.localizedDescription)", options: "Take me to studio :(",
											completion: { _ in self?.viewModel.input.onCancelActionTap.execute()})
			})
			.disposed(by: disposeBag)
		
		output
			.editorDataUpload
			.drive(onNext: { [weak self] result in
				switch result {
				case .success: break
				case .failure(let error):
					self?.presentAlertWithTitle(title: "Error loading editor data",
												message: "\(error.localizedDescription)", options: "Ok", completion: { _ in })
				}
			})
			.disposed(by: disposeBag)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// background of the editorpreview matches main colors in the image
		libraryItemPreview.image?.getColors { [weak self] colors in
			UIView.animate(withDuration: 0.3, animations: {
				self?.view.backgroundColor = colors?.background.withAlphaComponent(0.5)
				self?.navigationController?.navigationBar.backgroundColor = colors?.background.withAlphaComponent(0.5)
			})
		}
		
	}
	
	private func setupComponents() {
		
		var barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
		
		barButtonItem.setTitleTextAttributes([ NSAttributedString.Key.foregroundColor: UIColor.red,
											   NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		], for: .normal)
		barButtonItem.setTitleTextAttributes([ NSAttributedString.Key.foregroundColor: UIColor.red,
											   NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		], for: .selected)
		barButtonItem.setTitleTextAttributes([ NSAttributedString.Key.foregroundColor: UIColor.gray,
											   NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		], for: .disabled)
		
		navigationItem.setRightBarButtonItems([barButtonItem], animated: false)
		
		barButtonItem
			.rx
			.action = viewModel.input.onCancelActionTap
		
		let output = viewModel
			.output

		output
			.isLoading
			.not()
			.drive(barButtonItem.rx.isEnabled)
			.disposed(by: disposeBag)
		
		view.addSubview(loadingIndicator)
		loadingIndicator.center = view.center
		loadingIndicator.hidesWhenStopped = true
		
		exportButton
			.rx
			.tap
			.subscribe(onNext: { [weak self] in
				guard let image = self?.libraryItemPreview.image else { return }
				let activityViewController = UIActivityViewController(activityItems: [image],
																	  applicationActivities: nil)
				activityViewController.popoverPresentationController?.sourceView = self?.view
				self?.present(activityViewController, animated: true, completion: nil)
			}).disposed(by: disposeBag)

		createPostButton
			.rx
			.action = viewModel.input.onPostActionTap
	}
	
	private func setupUI() {
		
		title = "STUDIO"
		
		navigationItem.rightBarButtonItem?.tintColor = .black
		navigationItem.leftBarButtonItem?.tintColor = .black
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.black,
			NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		]
		view.backgroundColor = BRXNDColors.veryLightBlue
		
		playVideoIcon.isHidden = true
	}
}
