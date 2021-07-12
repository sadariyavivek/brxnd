//
//  PostsCoordinator.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-28.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class PostsCoordinator: BaseCoordinator {

	private let factory: PostsModuleFactory
	private let router: Router

	private var doesNeedUpdate: (() -> Void)?

	init(factory: PostsModuleFactory, router: Router) {
		self.factory = factory
		self.router = router
	}

	#if DEBUG
	deinit {
		print("\(self) deinited.")
	}
	#endif

	override func start() {
		showPosts()
	}

	private func showPosts() {
		let (containerVC, containerVM) = factory.makePostsModule()

		containerVM.coordinator.onItemSelect = { [weak self] post in
			self?.showEdit(with: post)
		}

		containerVM.coordinator.onLogInSocialMedia = { [weak self] in
			let facebookLoginManager = FacebookLoginManager.shared
			facebookLoginManager.logIn { _  in
				self?.doesNeedUpdate?()
			}
		}
		doesNeedUpdate = {
			containerVM.input.refresh()
		}

		router.setRootModule(containerVC, hideBar: true)
	}

	private func showEdit(with post: FeedData) {
		let (editPostVC, editPostVM) = factory.makePostEditModule(with: post)

		editPostVM.coordinator.onDoneTap = { [weak self] in
			self?.router.dismissModule()
		}

		editPostVM.coordinator.onExitTap = { [weak self] in
			self?.doesNeedUpdate?()
			self?.router.dismissModule()
		}

		router.present(editPostVC, animated: true, embedInNavController: true)
	}
}
