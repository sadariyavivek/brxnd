//
//  ScheduleCoordinator.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-23.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

fileprivate enum Style {
	case tableView
	case collectionView
}

final class ScheduleCoordinator: BaseCoordinator {

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
		showScheduled()
	}

	private func showScheduled(_ style: Style = .tableView) {

		switch style {
		case .tableView:
			let (scheduledTableViewVC,
				scheduledTableViewVM) = factory.makeScheduledPostsModule()

			scheduledTableViewVM.coordinator.onItemSelect = { [weak self] post in
				self?.showEdit(with: post)
			}

			scheduledTableViewVM.coordinator.onLogInSocialMedia = { [weak self] in
				let facebookLoginManager = FacebookLoginManager.shared
				facebookLoginManager.logIn { _  in
					self?.doesNeedUpdate?()
				}
			}
			doesNeedUpdate = {
				scheduledTableViewVM.input.refresh()
			}
			router.setRootModule(scheduledTableViewVC)

		case .collectionView:
			fatalError("Implement collectionView")
		}
	}

	private func showEdit(with post: FeedData) {
		let (editPostVC, editPostVM) = factory.makePostEditModule(with: post)

		editPostVC.isPublishNowButtonAvailable = true

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
