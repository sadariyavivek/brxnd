//
//  EditorPreviewViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Action

protocol EditorPreviewViewModelCoordinator: class {
	var onCancel: (() -> Void)? { get set }
	var onEdit: ((_ editorData: MediaItem) -> Void)? { get set }
	var onPost: ((_ editorData: MediaItem) -> Void)? { get set }
}

protocol EditorPreviewViewModelInput {
	var onEditActionTap: Action<Void, Void> { get }
	var onPostActionTap: Action<Void, Void> { get }
	var onCancelActionTap: Action<Void, Void> { get }

	var mediaItemSubject: BehaviorRelay<MediaItem> { get }
}

protocol EditorPreviewViewModelOutput {
	var isLoading: Driver<Bool> { get }
	var thumbnailImageFromStudioView: Driver<UIImage> { get }

	var onLoadingEditorDataError: Driver<Error>? { get }
	var editorDataUpload: Driver<Result<BRXNDEditorUploadResponse, Error>> { get }
}

protocol EditorPreviewViewModelType {
	var input: EditorPreviewViewModelInput { get }
	var output: EditorPreviewViewModelOutput { get }
	var coordinator: EditorPreviewViewModelCoordinator { get }
}

final class EditorPreviewViewModel: EditorPreviewViewModelInput,
	EditorPreviewViewModelOutput,
	EditorPreviewViewModelType,
	EditorPreviewViewModelCoordinator {
	
	var input: EditorPreviewViewModelInput { return self }
	var output: EditorPreviewViewModelOutput { return self}
	var coordinator: EditorPreviewViewModelCoordinator { return self }

	// MARK: - Input
	var mediaItemSubject: BehaviorRelay<MediaItem>

	// MARK: - Output
	var isLoading: Driver<Bool>
	var thumbnailImageFromStudioView: Driver<UIImage> {
		return mediaItemSubject.asDriver().map { $0.image }
	}
	var onLoadingEditorDataError: Driver<Error>?
	var editorDataUpload: Driver<Result<BRXNDEditorUploadResponse, Error>>

	// MARK: - Actions
	lazy var onCancelActionTap: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onCancel?()
			return Observable.just(())
		}
	}()

	lazy var onEditActionTap: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onEdit?(self.mediaItemSubject.value)
			return Observable.just(())
		}
	}()

	lazy var onPostActionTap: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onPost?(self.mediaItemSubject.value)
			return Observable.just(())
		}
	}()

	// MARK: - Coordinator
	var onCancel: (() -> Void)?
	var onEdit: ((MediaItem) -> Void)?
	var onPost: ((_ editorData: MediaItem) -> Void)?

	// MARK: - Private
	private var editorData: Single<Result<Data, Error>>?
	private let editorService: EditorServiceType

	init(editorService: EditorServiceType = EditorService(),
		 mediaItemSubject: BehaviorRelay<MediaItem>) {

		self.editorService = editorService
		self.mediaItemSubject = mediaItemSubject

		let loadingIndicator = RxActivityIndicator()

		self.isLoading = loadingIndicator
			.asDriver()
			.startWith(false)

		switch mediaItemSubject.value.mediaModifiers {
		case .isOriginal: break
		case .isEdited:
			guard let serializedID = mediaItemSubject.value.assetModel?.id else {
				fatalError("Image id not provided")
			}

			let editorRequest = editorService
				.getEditorSerializedData(id: serializedID)
				.asObservable()
				.trackActivity(loadingIndicator)
				.asSingle()
				.observeOn(MainScheduler.instance)
				.do(onSuccess: { result in
					switch result {
					case .success(let value):
						var copy = mediaItemSubject.value
						copy.mediaModifiers = MediaSource.isEdited(value)
						mediaItemSubject.accept(copy)
					case .failure:
						throw EditorServiceError.dataCorrupted
					}
				})

			editorData = editorRequest

			onLoadingEditorDataError = editorData
				.flatMap { result -> Driver<Error> in
					return result
						.asObservable()
						.materialize()
						.errors()
						.asDriver(onErrorJustReturn: EditorServiceError.dataCorrupted)
			}
		}

		let dataUpload = mediaItemSubject
			.skip(1)
			.map { mediaItem -> (StudioAssetTuple, ImageID) in
				switch mediaItem.mediaModifiers {
				case .isOriginal:
					throw EditorServiceError.dataCorrupted
				case .isEdited(let data):
					if
						let imageAsData = mediaItem.image.jpegData(compressionQuality: 1),
						let editorData = data,
						let id = mediaItem.assetModel?.id {
						return (StudioAssetTuple(imageAsData: imageAsData, editorData: editorData), id)
					} else {
						#if DEBUG
						fatalError("Editor data corrupted")
						#else
						throw EditorServiceError.dataCorrupted
						#endif
					}
				}
		}
		.flatMapLatest { (tuple, imageID) in
			return editorService
				.saveEditorSerializedData(id: imageID, studioAsset: tuple)
				.asObservable()
				.trackActivity(loadingIndicator)
				.asSingle()
				.observeOn(MainScheduler.instance)
		}
		.asDriver(onErrorJustReturn: Result.failure(EditorServiceError.dataCorrupted))

		editorDataUpload = dataUpload
	}
}
