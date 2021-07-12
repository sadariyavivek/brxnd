//
//  EditFlowCoordinator.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-05-01.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import PhotoEditorSDK

final class EditFlowCoordinator: BaseCoordinator, EditFlowCoordinatorOutput {

	deinit {
		print("\(self) deinited.")
	}

	private var doesNeedUpdateOnExit: Bool = false

	var finishFlow: ((_ needsUpdateOnExit: Bool) -> Void)?
	var onPostingFlow: ((_ mediaItem: MediaItem) -> Void)?

	private let router: Router
	private let libraryItem: MediaItem
	private let factory: EditFlowModuleFactory

	private var onEditorOutput: ((_ newImage: UIImage, _ newEditorData: StudioAssetTuple?) -> Void)?

	init(router: Router, libraryItem: MediaItem,
		 factory: EditFlowModuleFactory) {
		self.router = router
		self.libraryItem = libraryItem
		self.factory = factory
	}

	override func start() {
		showEditorPreview(libraryItem: libraryItem)
	}
	
	private func showEditorPreview(libraryItem: MediaItem) {
		let (previewView, previewVM) = factory.makeLibraryItemPreview(libraryItem: libraryItem)

		previewVM.coordinator.onEdit = { [weak self] item in
			self?.showEditor(with: item)
		}

		previewVM.coordinator.onCancel = { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.finishFlow?(strongSelf.doesNeedUpdateOnExit)
		}

		onEditorOutput = { [weak self] newImage, newData in
			var copy = previewVM.input.mediaItemSubject.value
			copy.image = newImage
			switch newData {
			case .none:
				copy.mediaModifiers = MediaSource.isOriginal(fromCamera: false)
			case .some(let newData):
				copy.mediaModifiers = MediaSource.isEdited(newData.editorData)
				self?.doesNeedUpdateOnExit = true
			}
			previewVM.input.mediaItemSubject.accept(copy)
			self?.router.dismissModule(animated: true, completion: nil)
		}

		previewVM.coordinator.onPost = { [weak self] item in
			self?.runPostingFlow(with: item)
		}

		router.setRootModule(previewView)
	}
	
	private func showEditor(with item: MediaItem) {
		switch item {
		case let item as PhotoMediaItem:
			showPhotoEditor(with: item)
		default:
			#if DEBUG
			fatalError("Not implemented")
			#endif
			break
		}
	}
	
	private func showPhotoEditor(with photo: PhotoMediaItem) {
		let photoEditor = factory.makePhotoEditor(photo: photo)
		let sdkCallbackDelegate = photoEditor as! PhotoEditViewController
		sdkCallbackDelegate.delegate = self as PhotoEditViewControllerDelegate
		router.present(photoEditor, animated: true)
	}

	private func runPostingFlow(with item: MediaItem) {
		onPostingFlow?(item)
	}

}

extension EditFlowCoordinator: PhotoEditViewControllerDelegate {
	func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
		if let editorData = photoEditViewController.serializedSettings(withImageData: true) {
			onEditorOutput?(image, StudioAssetTuple(imageAsData: data, editorData: editorData))
		} else {
			onEditorOutput?(image, nil)
		}
	}

	func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
		#if DEBUG
		fatalError("Handle failure")
		#endif
	}

	func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
		router.dismissModule(animated: true, completion: nil)
	}
}
