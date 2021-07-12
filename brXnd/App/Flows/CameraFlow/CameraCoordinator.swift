//
//  CameraCoordinator.swift
//  brXnd Dev
//
//  Created by Andrian Sergheev on 2019-02-20.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import AVFoundation

final class CameraCoordinator: BaseCoordinator, CameraCoordinatorOutput {
	
	#if DEBUG
	deinit {
		print("\(self) deinited.")
	}
	#endif

	var finishFlow: ((MediaItem?) -> Void)?

	private let factory: CameraModuleFactory
	private let router: Router

	init(router: Router, factory: CameraModuleFactory) {
		self.factory = factory
		self.router = router
	}
	override func start() {
		#if targetEnvironment(simulator)
		fatalError("Camera not working on simulator.")
		#else
		runCamera()
		#endif
	}

	private func runCamera() {
		let cameraVC = factory.makeCameraModule()
		cameraVC.onCancelTapped = { [weak self] in
			self?.finishFlow?(nil)
		}
		cameraVC.onTakePhotoTapped = { [weak self] output in
			self?.runCameraPreview(with: output)
		}
		cameraVC.onSwitchCameraTypeTapped = {
			fatalError("⚡️Video Camera not available and it has to be disabled!")
//			self?.runVideoCamera()
		}
		router.setRootModule(cameraVC, hideBar: true)
	}

	private func runCameraPreview(with photo: TemporaryPhotoItem) {
		let previewVC = factory.makeCameraPreview(photoItem: photo)

		previewVC.onSaveToAppTapped = { [weak self] output in
			self?.finishFlow?(output)
			self?.router.dismissModule()
		}
		previewVC.onDiscardTapped = { [weak self] in
			self?.router.popModule(animated: false)
		}
		router.push(previewVC, animated: false)
	}

//	private func runVideoCamera() {
//		let videoVC = factory.makeVideoCameraModule()
//
//		videoVC.onCancelTapped = { [weak self] in
//			self?.finishFlow?(nil)
//			self?.router.dismissModule()
//		}
//		videoVC.onTakeVideoTapped = { [weak self] output in
//			self?.runVideoPreview(video: output)
//		}
//		videoVC.onSwitchCameraTypeTapped = { [weak self] in
//			self?.runCamera()
//		}
//		router.setRootModule(videoVC, hideBar: true)
//	}

//	private func runVideoPreview(video: VideoMediaItem) {
//		let previewVC = factory.makeVideoCameraPreview(videoURL: video)
//
//		previewVC.onSaveToAppTapped = { [weak self] output in
//			self?.finishFlow?(output)
//			self?.router.dismissModule()
//		}
//		previewVC.onDiscardTapped = { [weak self] in
//			self?.router.popModule(animated: false)
//		}
//		router.push(previewVC, animated: false)
//	}
}
