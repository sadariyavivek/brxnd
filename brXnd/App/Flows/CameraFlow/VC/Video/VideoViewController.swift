//
//  VideoViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-04-08.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import AVKit

final class VideoViewController: UIViewController, VideoView, CKFSessionDelegate {

	var onTakeVideoTapped: ((VideoMediaItem) -> Void)?
	var onCancelTapped: (() -> Void)?
	var onSwitchCameraTypeTapped: (() -> Void)?

	deinit {
		videoView.session = nil
		print("VideoView session: \(self) is deinit.")
	}

	@IBOutlet weak var captureButton: UIButton!
	@IBOutlet weak var switchButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!

	@IBOutlet weak var zoomLabel: UILabel!
	@IBOutlet weak var recordingTimeLabel: UILabel!

	@IBOutlet weak var flashButton: UIButton!
	@IBOutlet weak var gridButton: UIButton!

	@IBOutlet weak var zoomVisualEffectView: UIVisualEffectView!
	@IBOutlet weak var recordingVisualEffectView: UIVisualEffectView!
	@IBOutlet weak var videoView: CKFPreviewView! {
		didSet {
			let session = CKFVideoSession()
			session.delegate = self

			self.videoView.autorotate = false
			self.videoView.session = session
			self.videoView.previewLayer?.videoGravity = .resizeAspectFill
		}
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}

	private func setupUI() {
		captureButton.layer.cornerRadius = 34
		captureButton.layer.borderWidth = 3
		captureButton.layer.borderColor = UIColor.white.cgColor
		captureButton.backgroundColor = UIColor.red.withAlphaComponent(0.3)
		captureButton.alpha = 0.8

		let image = UIImage(named: "library")?.withRenderingMode(.alwaysTemplate)
		cancelButton.setImage(image, for: .normal)
		cancelButton.tintColor = .white

		zoomVisualEffectView.layer.cornerRadius = 3
		recordingVisualEffectView.layer.cornerRadius = 3
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	@IBAction func cancelButton(_ sender: UIButton) {
		sender.isEnabled = false
		self.onCancelTapped?()
	}
	@IBAction func switchButton(_ sender: UIButton) {
		sender.isEnabled = false
		self.onSwitchCameraTypeTapped?()
	}

	let videoURLWithDate: URL = {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let videoURL = paths[0].appendingPathComponent("\(String(describing: Current.date())).mov")
		try? FileManager.default.removeItem(at: videoURL)
		return videoURL
	}()

	@IBAction func captureButton(_ sender: UIButton) {
		if let session = videoView.session as? CKFVideoSession {
			switch session.isRecording {
			case true:
				sender.backgroundColor = UIColor.red.withAlphaComponent(0.3)
				session.stopRecording()
				stopAnimatingWithPulse(view: sender as UIView)
				recordingTimeLabel.text = "0:0"
			case false:
				animateWithPulse(view: sender as UIView)
				sender.backgroundColor = UIColor.red.withAlphaComponent(0.9)
				session.record(url: videoURLWithDate, { [weak self] videoURL in
					let videoItem = VideoMediaItem(videoURL: videoURL, name: String(describing: Current.date()))
					self?.onTakeVideoTapped?(videoItem)
				}) { err in
					fatalError("\(err)")
				}
			}
		}
	}

	@IBAction func flasButton(_ sender: UIButton) {
		guard let cameraSession = videoView.session as? CKFVideoSession else { return }
		let values: [CKFVideoSession.FlashMode] = [.auto, .on, .off]

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
		guard let camera = videoView else { return }
		let gridOn = videoView.showGrid
		camera.showGrid = !gridOn
	}

	func didChangeValue(session: CKFSession, value: Any, key: String) {
		switch key {
		case "zoom":
			self.zoomLabel.text = String(format: "%.1fx", value as? Double ?? 1.0)
		case "duration":
			if let value = value as? Double {
				let tuple = rawSecondsToMinutesAndSeconds(seconds: value)
				//1 sec offset.
				self.recordingTimeLabel.text = recordingFormatter(minutes: tuple.0, seconds: tuple.1 + 1)
			}
		default:
			break
		}

	}

	private func animateWithPulse(view: UIView) {
		let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
		pulseAnimation.duration = 1
		pulseAnimation.fromValue = 0.5
		pulseAnimation.toValue = 1
		pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
		pulseAnimation.autoreverses = true
		pulseAnimation.repeatCount = .greatestFiniteMagnitude
		view.layer.add(pulseAnimation, forKey: "animateOpacity")
	}
	private func stopAnimatingWithPulse(view: UIView) {
		view.layer.removeAnimation(forKey: "animateOpacity")
	}
}

final class VideoPreviewController: UIViewController, VideoPreview {

	#if DEBUG
	deinit {
		print("Video Preview View: \(self) deinited.")
	}
	#endif

	var onDiscardTapped: (() -> Void)?
	var onSaveToAppTapped: ((VideoMediaItem) -> Void)?

	@IBOutlet weak var toolbar: UIToolbar!
	@IBOutlet weak var discardBarButton: UIBarButtonItem!
	@IBOutlet weak var saveToAppButton: UIBarButtonItem!
	@IBOutlet weak var videoView: UIView!

	var videoItem: VideoMediaItem!

	let player = AVPlayerViewController()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()

		player.player = AVPlayer(url: videoItem.itemURL)
		player.videoGravity = .resizeAspectFill
		player.view.frame = videoView.bounds
		videoView.addSubview(player.view)
		player.player?.play()
	}

	override var prefersStatusBarHidden: Bool {
		return true
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

	@IBAction func onDiscardTapped(_ sender: UIBarButtonItem) {onDiscardTapped?()}
	@IBAction func onSaveTapped(_ sender: UIBarButtonItem) {
		onSaveToAppTapped?(videoItem)}
}

fileprivate func rawSecondsToMinutesAndSeconds(seconds: Double) -> (Int, Int) {
	let intSeconds = Int(seconds)
	return ((intSeconds % 3600) / 60, (intSeconds % 3600) % 60)
}

fileprivate func recordingFormatter(minutes: Int, seconds: Int) -> String {
	return "\(minutes):\(seconds)"
}
