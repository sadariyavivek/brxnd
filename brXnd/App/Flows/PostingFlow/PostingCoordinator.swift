//
//  PostingCoordinator.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-12.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class PostingCoordinator: BaseCoordinator, PostingFlowCoordinatorOutput {

	private let factory: PostingModuleFactory
	private let router: Router

	var finishFlow: ((_ needsUpdateOnExit: Bool) -> Void)?
	var mediaItem: MediaItem

	init(factory: PostingModuleFactory, router: Router, mediaItem: MediaItem) {
		self.factory = factory
		self.router = router
		self.mediaItem = mediaItem
	}

	#if DEBUG
	deinit {
		print("\(self) deinited.")
	}
	#endif

	override func start() {
		showPosting()
	}

	private func showPosting() {
		let (vc, vm) = factory.makePostingModule(with: mediaItem)

		vm.coordinator.onFinish = { [weak self] in
			self?.finishFlow?(false)
		}
		router.setRootModule(vc)
	}

}
