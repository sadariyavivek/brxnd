//
//  ModuleFactoryImp.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-01-30.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Device
import PhotoEditorSDK

final class ModuleFactoryImp: OnboardingModuleFactory,
	AuthModuleFactory,
	StudioModuleFactory,
	SettingsModuleFactory,
	CameraModuleFactory,
	EditFlowModuleFactory,
	PostsModuleFactory,
PostingModuleFactory {

	//Login
	func makeLoginModule() -> (LoginView, LoginViewModel) {
		let vc = LoginViewController.controllerFromStoryboard(.auth)
		let vm = LoginViewModel(loginAPI: UserLoginAPI())
		vc.vm = vm
		return (vc, vm)
	}

	func makeSignUpModule() -> (SignUpView, SignUpViewModel) {
		let vc = SignUpViewController.controllerFromStoryboard(.auth)
		let vm = SignUpViewModel()
		vc.vm = vm
		return (vc, vm)
	}

	func makeTermsModule() -> TermsView {
		return TermsViewController.controllerFromStoryboard(.auth)
	}

	func makeOnboardingStepsModule() -> StepsView {
		return PageViewController.controllerFromStoryboard(.onboarding)
	}

	//Studio view
	func makeItemModule() -> (StudioContainerView, StudioViewModelType) {
		var vc: StudioContainerView!
		switch Device.size() {
		case .screen4Inch:
			/// for 4 inch screens, alternative layout
			let storyboard = UIStoryboard(name: "Studio", bundle: nil)
			let identifier = "StudioContainerViewController4InchScreen"
			vc = StudioContainerViewController.controllerInStoryboard(storyboard,
																	  identifier: identifier)
		default:
			/// usual layout
			vc = StudioContainerViewController.controllerFromStoryboard(.items)
		}
		let vm = StudioViewModel(studioService: StudioService())
		vc.viewModel = vm
		return (vc, vm)
	}

	func makeBrandCreationModule() -> (NewBrandView, NewBrandViewModelType) {
		let vc = NewBrandViewController.controllerFromStoryboard(.items)
		let vm = NewBrandViewModel()
		vc.viewModel = vm
		return (vc, vm)
	}

	//Create settings
	func makeSettingsModule() -> (SettingsView, SettingsViewModelType) {
		let vc = SettingsTableViewController.controllerFromStoryboard(.settings)
		let vm = SettingsViewModel()
		vc.viewModel = vm
		return (vc, vm)
	}

	func makeSettingsTerms(with data: String) -> SettingsTermsView {
		let vc = SupportViewController.controllerFromStoryboard(.settings)
		vc.textToPresent = data
		return vc
	}

	func makeSocialMediaModule() -> SocialMediaSettingsTableViewController {
		let vc = SocialMediaSettingsTableViewController.controllerFromStoryboard(.settings)
		return vc
	}

	//Photo Camera
	func makeCameraModule() -> CameraView {
		let vc = CameraViewController.controllerFromStoryboard(.camera)
		return vc
	}
	func makeCameraPreview(photoItem: TemporaryPhotoItem) -> CameraPreview {
		let vc = PhotoPreviewViewController.controllerFromStoryboard(.camera)
		vc.image = photoItem
		return vc
	}

	//Video Camera
	func makeVideoCameraModule() -> VideoView {
		let vc = VideoViewController.controllerFromStoryboard(.camera)
		return vc
	}
	
	//	func makeVideoCameraPreview(videoURL: VideoMediaItem) -> VideoPreview {
	//		let vc = VideoPreviewController.controllerFromStoryboard(.camera)
	//		vc.videoItem = videoURL
	//		return vc
	//	}
	//	func makeVideoEditor(video: VideoMediaItem) -> VideoEditorView {
	//		return VideoEditorViewController()
	//	}

	//Editor Flow
	func makeLibraryItemPreview(libraryItem: MediaItem) -> (EditorPreviewView, EditorPreviewViewModel) {
		let vc = EditorPreviewViewController.controllerFromStoryboard(.edit)
		let vm = EditorPreviewViewModel(mediaItemSubject: BehaviorRelay(value: libraryItem))
		vc.viewModel = vm
		return (vc, vm)
	}

	func makePhotoEditor(photo: PhotoMediaItem) -> PhotoEditorView {

		EditorSDKConfig.shared.retrieveBrandLogo()

		switch photo.mediaModifiers {
		case .isEdited(let data):
			guard let data = data else { fatalError("[Photo SDK] Can't retrieve data from \(photo)")}

			let deserializedData = Deserializer.deserialize(data: data, imageDimensions: nil)

			if let model = deserializedData.model, let photoIMG = deserializedData.photo {
				let photoAsset: Photo
				if let url = photoIMG.url {
					photoAsset = Photo(url: url)
				} else if let data = photoIMG.data {
					photoAsset = Photo(data: data)
				} else if let image = photoIMG.image {
					photoAsset = Photo(image: image)
				} else {
					fatalError("[Photo SDK] Can't parse photo or model from \(photo)")
				}
				let editorVC = PhotoEditViewController(photoAsset: photoAsset, configuration: EditorSDKConfig.shared.config, photoEditModel: model)
				return editorVC
			} else { fatalError("[Photo SDK] Can't deserialize data from \(photo)")}
		case .isOriginal:
			let photo = Photo(image: photo.image)
			let editorVC = PhotoEditViewController(photoAsset: photo,
												   configuration: EditorSDKConfig.shared.config)
			return editorVC
		}
	}

	//Posts flow
	func makePostsModule() -> (PostsView, PostsViewModelType) {
		let vc = PostsViewControllerContainer.controllerFromStoryboard(.posts)
		let vm = PostsViewModel(postsService: PostsFeedService())
		vc.viewModel = vm
		return (vc, vm)
	}

	func makePostEditModule(with post: FeedData) -> (PostEditView, PostsEditViewModelType) {
		let vc = PostEditViewController.controllerFromStoryboard(.posts)
		let vm = PostsEditViewModel(postsService: PostsFeedService(),
									scheduleService: ScheduleService(),
									postData: post)
		vc.viewModel = vm
		return (vc, vm)
	}
	
	func makeScheduledPostsModule() -> (ScheduledView, ScheduledViewModelType) {
		let vc = ScheduledTableViewController.controllerFromStoryboard(.posts)
		let vm = ScheduledViewModel(postsService: PostsFeedService(),
									scheduleService: ScheduleService())
		vc.viewModel = vm
		return (vc, vm)
	}

	//Posting flow
	func makePostingModule(with dependency: MediaItem) -> (PostingView, PostingViewModelType) {
		let vc = PostingContainerViewController.controllerFromStoryboard(.posting)
		let vm = PostingViewModel(postsService: PostsFeedService(), mediaItem: dependency)
		vc.viewModel = vm
		return (vc, vm)
	}

}
