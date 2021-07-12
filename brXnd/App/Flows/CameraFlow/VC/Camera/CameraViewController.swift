//
//  CameraViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-20.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import AVFoundation
import NVActivityIndicatorView

final class CameraViewController: UIViewController, CameraView, CKFSessionDelegate {

	var onTakePhotoTapped: ((TemporaryPhotoItem) -> Void)?
	var onCancelTapped: (() -> Void)?
	var onSwitchCameraTypeTapped: (() -> Void)?

	deinit {
		cameraView.session = nil
		print("Camera View: \(self) deinited.")
	}

	@IBOutlet weak var captureButton: UIButton!
	@IBOutlet weak var switchButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!

	@IBOutlet weak var flashButton: UIButton!
	@IBOutlet weak var gridButton: UIButton!

	@IBOutlet weak var zoomLabel: UILabel!
	@IBOutlet weak var visualEffectView: UIVisualEffectView!

	@IBOutlet weak var cameraView: CKFPreviewView! {
		didSet {
			let session = CKFPhotoSession()
			session.resolution = CGSize(width: 3024, height: 4032)
			session.delegate = self

			self.cameraView.autorotate = false
			self.cameraView.session = session
			self.cameraView.previewLayer?.videoGravity = .resizeAspectFill
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupComponents()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(false)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	@IBAction func cancelButton(_ sender: UIButton) {
		sender.isEnabled = false
		self.onCancelTapped?()
	}
	@IBAction func switchButton(_ sender: UIButton) {
		sender.isEnabled = false
		self.onSwitchCameraTypeTapped?()
	}

	@IBAction func captureButton(_ sender: UIButton) {
		flash()
		if let captureSession = self.cameraView.session as? CKFPhotoSession {
			captureSession.capture({ [unowned self] (capturedImage, capturedImagePropreties) in
				let tempPhoto = TemporaryPhotoItem(image: capturedImage, settings: capturedImagePropreties)
				self.onTakePhotoTapped?(tempPhoto)
			}) { error in
				fatalError("Camera failed to take photo: \(error)")
			}
		}
	}

	@IBAction func flashButton(_ sender: UIButton) {
		guard let cameraSession = cameraView.session as? CKFPhotoSession else { return }
		let values: [CKFPhotoSession.FlashMode] = [.auto, .on, .off]
		let currentValue = cameraSession.flashMode

		cameraSession.flashMode =
			values.item(after: currentValue) ?? CKFVideoSession.FlashMode.auto

		switch cameraSession.flashMode {
		case .auto:
			sender.setImage(UIImage(named: "flashAuto"), for: .normal)
		case .off:
			sender.setImage(UIImage(named: "flashOff"), for: .normal)
		case .on:
			let image = UIImage(named: "flashOn")?.withRenderingMode(.alwaysTemplate)
			sender.tintColor = UIColor.yellow
			sender.setImage(image, for: .normal)
		}
	}

	@IBAction func gridButton(_ sender: UIButton) {
		guard let camera = cameraView else { return }
		let gridOn = cameraView.showGrid
		camera.showGrid = !gridOn
	}
	private func flash() {
		cameraView.alpha = 0.1
		//cameraView.setNeedsDisplay()
		UIView.animate(withDuration: 0.3, animations: { [weak self] in
			self?.cameraView.alpha = 1
		})
	}

	private func setupUI() {
		captureButton.layer.cornerRadius = 34
		captureButton.layer.borderWidth = 3
		captureButton.layer.borderColor = UIColor.white.cgColor
		captureButton.backgroundColor = UIColor.blue
		captureButton.alpha = 0.8

		let image = UIImage(named: "library")?.withRenderingMode(.alwaysTemplate)
		cancelButton.setImage(image, for: .normal)
		cancelButton.tintColor = .white

		visualEffectView.layer.cornerRadius = 3
	}

	private func setupComponents() {
		//gridButton.setBackgroundImage(UIImage(named: "gridIcon"), for: .normal)
		
		// MARK: - Video capabillity is disabled.

		switchButton.isEnabled = false
		switchButton.isHidden = true
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	// camera delegate
	func didChangeValue(session: CKFSession, value: Any, key: String) {
		// listening for changes in the cfk session camera settings
		if key == "zoom" {zoomLabel.text = String(format: "%.1fx", value as? Double ?? 1.0)}
	}

}

final class PhotoPreviewViewController: UIViewController, UIScrollViewDelegate, CameraPreview, NVActivityIndicatorViewable {

	#if DEBUG
	deinit {
		print("Camera Preview View: \(self) deinited.")
	}
	#endif

	var onSaveToAppTapped: ((PhotoMediaItem) -> Void)?
	var onDiscardTapped: (() -> Void)?

	@IBOutlet weak var toolbar: UIToolbar!
	@IBOutlet weak var discardBarButton: UIBarButtonItem!
	@IBOutlet weak var saveToAppButton: UIBarButtonItem!

	var image: TemporaryPhotoItem!

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageView: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.imageView.image = image.image
		scrollView.delegate = self
		setupUI()
	}

	private func setupUI() {
		//colors
		toolbar.alpha = 0.8

		discardBarButton.tintColor = UIColor.black
		saveToAppButton.tintColor = UIColor.black
		saveToAppButton.style = .done
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	private func createPhoto(item: TemporaryPhotoItem) -> PhotoMediaItem {
		let normalizedImage = item.image.fixOrientation()
		let photo = PhotoMediaItem(image: normalizedImage, mediaModifiers: .isOriginal(fromCamera: true), assetModel: nil)
		return photo
	}

	@IBAction func onDiscardTapped(_ sender: UIBarButtonItem) {onDiscardTapped?()}
	@IBAction func onSaveTapped(_ sender: UIBarButtonItem) {
		DispatchQueue.main.async { [unowned self] in
			self.startAnimating()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [unowned self] in
			let outImage = self.createPhoto(item: self.image)
			self.stopAnimating()
			self.onSaveToAppTapped?(outImage)
		}
	}
	private func startAnimating() {
		startAnimating(nil, message: nil,
					   messageFont: nil,
					   type: .circleStrokeSpin,
					   color: nil,
					   padding: nil,
					   displayTimeThreshold: nil,
					   minimumDisplayTime: nil,
					   backgroundColor: nil,
					   textColor: nil,
					   fadeInAnimation: nil)
	}
}
