//
//  ItemCoordinator.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class StudioCoordinator: BaseCoordinator {
	
	#if DEBUG
	deinit {
		print("\(self) deinited.")
	}
	#endif
	
	private let factory: StudioModuleFactory
	private let coordinatorFactory: CoordinatorFactory
	private let router: Router
	
	private var onCameraOutput: ((MediaItem) -> Void)?
	private var needsStudioRefresh: ((Bool) -> Void)?
	private var onShowNotLoggedInSocialMediaAlert: (() -> Void)?

	init(router: Router, factory: StudioModuleFactory, coordinatorFactory: CoordinatorFactory) {
		self.factory = factory
		self.router = router
		self.coordinatorFactory = coordinatorFactory
	}
	
	override func start() {
		showStudio()
	}
	
	private func showStudio() {
		let (itemsVC, itemsVM) = factory.makeItemModule()
		itemsVM.coordinator.onItemSelect = { [weak self] item in
			self?.runEditFlow(with: item)
		}
		itemsVM.coordinator.onCreateNewLogo = { [weak self] in
			self?.createNewBrandFlow()
		}
		itemsVM.coordinator.onCameraClicked = { [weak self] in
			self?.runCamera()
		}
		needsStudioRefresh = {
			$0 ? itemsVM.input.refresh() : ()
		}
		onCameraOutput = { photoItem in
			itemsVM.input.newStudioAssetUpload.accept(photoItem.asPNGImageData())
		}
		onShowNotLoggedInSocialMediaAlert = {
			itemsVC.showSocialMediaAlert()
		}
		router.setRootModule(itemsVC)
	}
	
	private func runCamera() {
		let (coordinator, module) = coordinatorFactory.makeCameraCoordinatorBox()
		coordinator.finishFlow = { [weak self, weak coordinator] cameraResponse in
			self?.router.dismissModule(animated: false, completion: nil)
			self?.removeDependency(coordinator)
			if let resp = cameraResponse {
				self?.onCameraOutput?(resp)
			}
		}
		self.addDependency(coordinator)
		module?.toPresent()?.modalPresentationStyle = .fullScreen
		router.present(module, animated: false)
		coordinator.start()
	}
	
	private func runEditFlow(with item: MediaItem) {
		let (coordinator, module) = coordinatorFactory.makeLibraryItemEditorCoordinatorBox(with: item)
		coordinator.finishFlow = { [weak self, weak coordinator] doesNeedUpdate in
			self?.router.dismissModule(animated: true, completion: nil)
			self?.removeDependency(coordinator)
			self?.needsStudioRefresh?(doesNeedUpdate)
		}

		coordinator.onPostingFlow = { [weak self, weak coordinator] item in
			self?.router.dismissModule(animated: true, completion: nil)
			self?.removeDependency(coordinator)
			self?.runPostingFlow(with: item)
		}

		self.addDependency(coordinator)
		router.present(module)
		coordinator.start()
	}
	
	private func createNewBrandFlow() {
		let (newBrandVC, newBrandVM) = factory.makeBrandCreationModule()
		newBrandVM.coordinator.onDismiss = { [weak self] success in
			self?.router.dismissModule()
			self?.needsStudioRefresh?(success)
		}
		router.present(newBrandVC, animated: true, embedInNavController: true)
	}

	private func runPostingFlow(with dependency: MediaItem) {

		switch Current.getLoggedInState() {
		case .loggedInWeb:
			self.onShowNotLoggedInSocialMediaAlert?()
		case .loggedInFacebook:
			let (coordinator, module) = coordinatorFactory.makePostingCoordinatorBox(with: dependency)

			coordinator.finishFlow = { [weak self, weak coordinator] _ in
				self?.router.dismissModule(animated: true, completion: nil)
				self?.removeDependency(coordinator)
			}
			self.addDependency(coordinator)
			router.present(module)
			coordinator.start()
		}
	}

}
