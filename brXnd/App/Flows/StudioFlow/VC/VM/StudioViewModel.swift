//
//  ItemCollectionViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-20.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Action
import RxFeedback

// swiftlint:disable all
private typealias studioTuple = ([BrandAsset], BrandResponse)
private typealias isPaginated = Bool
private typealias assetsTuple = ([BrandAsset], isPaginated)
public typealias trigger = Int
// swiftlint:enable all

private struct LoadNext: Equatable {
	let lastAssetID: Int
	let currentBrandID: Int
}

private enum StudioEvent {

	//user actions
	case refresh
	case reachedBottom
	case selectNewBrand(BrandID?, BrandData?)

	//reactions
	case initial(BrandResponse)
	case studioResponse(studioTuple)
	case studioAssetsResponse(assetsTuple)
	case error(Error)
}

private struct StudioState {

	var isRefreshing: Bool
	var isLoadingNext: Bool
	var shouldLoadFirstBrand: trigger

	var currentBrandID: BrandID?
	var currentSelectedBrand: BrandData?
	var brands: [BrandData]

	var brandAssets: [BrandAsset]
	var lastAssetID: Int?

	var error: Error?

	init(brandID: BrandID? = nil) {

		self.isRefreshing = true
		self.isLoadingNext = true
		self.shouldLoadFirstBrand = 0

		self.currentBrandID = brandID
		self.currentSelectedBrand = nil
		self.brands = []

		self.brandAssets = []
		self.lastAssetID = nil

		self.error = nil
	}
}

private extension StudioState {

	static func defaultState(_ brandID: BrandID?) -> StudioState {
		return StudioState(brandID: brandID)
	}

	var shouldRefreshStudio: BrandID? {
		return self.isRefreshing ? self.currentBrandID : nil
	}
	var shouldLoadNext: LoadNext? {
		if let asset = self.lastAssetID, let brand = self.currentBrandID {
			return self.isLoadingNext ? LoadNext(lastAssetID: asset, currentBrandID: brand) : nil
		} else {
			return nil
		}
	}
}

private extension StudioState {
	static func reduce(state: StudioState, command: StudioEvent) -> StudioState {
		var result = state
		switch command {
		// user actions
		case .refresh:

			if result.currentBrandID == nil ||
				result.currentSelectedBrand == nil {
				///used to trigger the firstBrandFeedbackLoop, as just setting it to "true" does not trigger a loop
				result.shouldLoadFirstBrand += 1
			} else {
				result.isRefreshing = true

			}
			result.isLoadingNext = false
			result.error = nil
			result.lastAssetID = nil
			return result
		case .reachedBottom:
			result.isLoadingNext = true
			return result
		case .selectNewBrand(let newBrand):
			result.currentBrandID = newBrand.0
			result.currentSelectedBrand = newBrand.1
			result.isLoadingNext = false
			result.isRefreshing = true
			result.lastAssetID = nil
			result.error = nil
			return result

		// machine feedback
		case .initial(let response):
			result.currentBrandID = response.brands?.data?.first?.id
			result.currentSelectedBrand = response.brands?.data?.first
			result.brands = response.brands?.data ?? []
			result.error = nil
			result.isRefreshing = true
			result.isLoadingNext = false
			return result
		case .studioAssetsResponse(let response):
			if response.1 {
				result.brandAssets += response.0
			} else {
				result.brandAssets = response.0
			}
			result.isRefreshing = false
			result.isLoadingNext = false
			result.error = nil
			result.lastAssetID = response.0.last?.id
			return result
		case .studioResponse(let tuple):
			result.isRefreshing = false
			result.error = nil
			result.brandAssets = tuple.0
			result.brands = tuple.1.brands?.data ?? []
			result.lastAssetID = tuple.0.last?.id
			result.isLoadingNext = false
			return result
		case .error(let error):
			#if DEBUG
			print("\(self) received error: \(error) 🌈")
			#endif

			result.error = nil
			result.error = error

			result.brands = []
			result.brandAssets = []

			result.isRefreshing = false
			result.isLoadingNext = false
			result.lastAssetID = nil

			return result
		}
	}
}

protocol StudioViewModelCoordinator: class {
	var onCameraClicked: (() -> Void)? { get set }
	var onItemSelect: ((_ item: MediaItem) -> Void)? { get set }
	var onCreateNewLogo: (() -> Void)? { get set }
}

protocol StudioViewModelInput {

	var cameraClickedAction: Action<Void, Void> { get }
	var itemSelectedAction: Action<MediaItem, Void> { get }
	var createNewLogoAction: Action<Void, Void> { get }

	var selectedBrand: PublishRelay<BrandData> { get }
	var loadMoreStudioItems: PublishRelay<Bool> { get }

	var newStudioAssetUpload: PublishRelay<Data> { get }

	var deleteStudioItem: PublishRelay<CellID> { get }
	var deleteBrand: PublishRelay<BrandID> { get }

	func refresh()
}

protocol StudioViewModelOutput {

	var brands: Driver<[BrandData]> { get }
	var studioItems: Driver<[BrandAsset]> { get }

	var brandMutationButtonsEnabled: Driver<Bool> { get }

	var deleteStudioItemResponse: Driver<Result<BRXNDCreateOrDeleteResponse, Error>>! { get }
	var deleteBrandResponse: Driver<Result<BRXNDCreateOrDeleteResponse, Error>>! { get }
	var uploadNewAssetResponse: Driver<Result<BRXNDStudioAssetUploadResponse, Error>>! { get }

	var isRefreshing: Driver<Bool> { get }
	var error: Driver<Error?> { get }
}

protocol StudioViewModelType {
	var input: StudioViewModelInput { get }
	var output: StudioViewModelOutput { get }
	var coordinator: StudioViewModelCoordinator { get }
}

final class StudioViewModel: StudioViewModelType,
	StudioViewModelInput,
	StudioViewModelOutput,
	StudioViewModelCoordinator {

	var input: StudioViewModelInput { return self }
	var output: StudioViewModelOutput { return self }
	var coordinator: StudioViewModelCoordinator { return self }

	// MARK: - Coordinator
	var onCameraClicked: (() -> Void)?
	var onItemSelect: ((MediaItem) -> Void)?
	var onCreateNewLogo: (() -> Void)?

	// MARK: - Input
	var selectedBrand 			= 	PublishRelay<BrandData>()
	var loadMoreStudioItems 	= 	PublishRelay<Bool>()

	var deleteBrand				= 	PublishRelay<BrandID>()
	var deleteStudioItem		=	PublishRelay<CellID>()
	var newStudioAssetUpload 	= 	PublishRelay<Data>()

	// MARK: - Output
	var brands: Driver<[BrandData]>
	var studioItems: Driver<[BrandAsset]>
	var brandMutationButtonsEnabled: Driver<Bool>

	var deleteBrandResponse: Driver<Result<BRXNDCreateOrDeleteResponse, Error>>!
	var deleteStudioItemResponse: Driver<Result<BRXNDCreateOrDeleteResponse, Error>>!
	var uploadNewAssetResponse: Driver<Result<BRXNDStudioAssetUploadResponse, Error>>!

	var isRefreshing: Driver<Bool>
	var error: Driver<Error?>

	// MARK: - Action
	lazy var itemSelectedAction: Action<MediaItem, Void> = {
		return Action<MediaItem, Void> { [unowned self] item in
			self.onItemSelect?(item)
			return Observable.just(())
		}
	}()

	lazy var cameraClickedAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onCameraClicked?()
			return Observable.just(())
		}
	}()

	lazy var createNewLogoAction: Action<Void, Void> = {
		return Action<Void, Void> { [unowned self] in
			self.onCreateNewLogo?()
			return Observable.just(())
		}
	}()

	func refresh() {refreshProperty.accept(())}

	// MARK: - Private
	private let disposeBag = DisposeBag()
	private let refreshProperty = PublishRelay<Void>()
	private let studioService: BrandServiceType & StudioServiceType
	private let editorSDKSingleton: EditorSDKConfig

	/// Used to initialize the ViewModel prior being assigned to a particular ViewController
	/// hence they do not hold the state by themselves, only propagate it,
	/// mutations of the state should be done in the reduce func.
	private let assetsSubject: BehaviorRelay<[BrandAsset]> = BehaviorRelay(value: [])
	private let brandsSubject: BehaviorRelay<[BrandData]> = BehaviorRelay(value: [])
	private let brandMutationSubjectEnabled: BehaviorRelay<Bool> = BehaviorRelay(value: false)
	private let errorSubject: BehaviorRelay<Error?> = BehaviorRelay(value: nil)

	init(studioService: BrandServiceType & StudioServiceType,
		 editorSDKSingleton: EditorSDKConfig = EditorSDKConfig.shared) {

		self.editorSDKSingleton = editorSDKSingleton

		self.studioService = studioService

		let activityIndicator = RxActivityIndicator()

		self.isRefreshing = activityIndicator
			.asDriver()

		self.brands = self.brandsSubject
			.asDriver()

		self.studioItems = self.assetsSubject
			.asDriver()

		self.error = self.errorSubject
			.asDriver()

		self.brandMutationButtonsEnabled = self.brandMutationSubjectEnabled
			.asDriver()

		let bindSubjects: (Driver<StudioState>) -> Signal<StudioEvent> = bind(self) { [unowned self] this, state in

			let subscriptions = [
				state.map { $0.brandAssets }.drive(self.assetsSubject),
				state.map { $0.brands }.drive(self.brandsSubject),
				state.map { $0.error }.drive(self.errorSubject),
				state.map { $0.brands }.map { $0.isEmpty ? false : true }.drive(self.brandMutationSubjectEnabled)
			]

			let events: [Signal<StudioEvent>] = [
				this.refreshProperty.asSignal().map { StudioEvent.refresh },
				this.selectedBrand.asSignalEmptyError().map { brandData -> (Int?, BrandData?) in
					if brandData.id == BRXNDMock.brand.id {
						self.createNewLogoAction.execute()
						return (nil, nil)
					} else {
						return (brandData.id, brandData)
					}
				}
				.filter { $0 != nil && $1 != nil }
				.map { id, data in StudioEvent.selectNewBrand(id, data)},
				this.loadMoreStudioItems.asSignalEmptyError().skip(1).map { _ in StudioEvent.reachedBottom }
			]
			return Bindings(subscriptions: subscriptions, events: events)
		}

		let firstBrandFeedbackLoop: (Driver<StudioState>) -> Signal<StudioEvent> =
			react(request: {$0.shouldLoadFirstBrand}, effects: { _ in
				return studioService
					.fetchBrands()
					.trackActivity(activityIndicator)
					.map { result in
						switch result {
						case .success(let value):
                            print(value.brands?.data)
							return value
						case .failure(let error):
							throw error
						}
				}
				.map { response in StudioEvent.initial(response) }
				.asSignal(onErrorJustReturn: StudioEvent.error(StudioServiceError.emptyBrands))
			})

		let refreshFeedbackLoop: (Driver<StudioState>) -> Signal<StudioEvent> =
			react(request: { $0.shouldRefreshStudio }, effects: { brandID in

				let brands = studioService
					.fetchBrands()
					.trackActivity(activityIndicator)
					.map { result -> BrandResponse in
						switch result {
						case .success(let value):
							return value
						case .failure(let error):
							throw error
						}
				}

				let assets = studioService
					.fetchBrandAssets(for: String(brandID))
					.trackActivity(activityIndicator)
					.map { result -> [BrandAsset]? in
						switch result {
						case .success(let value):
							return value.media
						case .failure:
							return []
						}
				}
				.compactMap { $0 }
				.asSignal(onErrorJustReturn: [])

				return Observable.zip(assets.asObservable(), brands)
					.map { tuple in StudioEvent.studioResponse(tuple)}
					.asSignal(onErrorJustReturn: StudioEvent.error(StudioServiceError.empty))
			})

		let studioPaginationFeedbackLoop: (Driver<StudioState>) -> Signal<StudioEvent> =
			react(request: {$0.shouldLoadNext }, effects: { loadNext in
				return studioService
					.fetchNextBrandAssets(for: String(loadNext.currentBrandID),
										  lastAssetID: loadNext.lastAssetID)
					///error can be ignored
					.map(extractSuccess)
					.compactMap { $0 }
					.map { $0.media }
					.compactMap { $0 }
					.asSignal(onErrorJustReturn: [])
					.map { response in StudioEvent.studioAssetsResponse(assetsTuple(response, true))}
			})

		let feedbackLoops: [(Driver<StudioState>) -> Signal<StudioEvent>] = [
			bindSubjects,
			firstBrandFeedbackLoop,
			refreshFeedbackLoop,
			studioPaginationFeedbackLoop
		]

		// MARK: - ViewModel State Machine
		let viewModelState = Driver.system(initialState: StudioState.defaultState(nil),
										   reduce: StudioState.reduce,
										   feedback: feedbackLoops)

		viewModelState
			.drive()
			.disposed(by: disposeBag)

		viewModelState
			.asObservable()
			.subscribe(onNext: { state in
				if let brandURL = state.currentSelectedBrand?.logoPath,
					let url = URL(string: BRXNDBaseURL.url.absoluteString + brandURL) {
					editorSDKSingleton.currentBrandLogoURL = url
				}
			}).disposed(by: disposeBag)

		//		#if DEBUG
		//		viewModelState
		//			.asObservable()
		//			.subscribe(onNext: { state in
		//				print("💥 State changed: \(state) , Brand ID: \(String(describing: state.currentBrandID))")
		//			}).disposed(by: disposeBag)
		//		#endif

		/* Refactor into the state machine */

		let deleteBrandAssetResponse = deleteStudioItem
			.flatMapLatest { itemID in
				return studioService
					.delete(studioItem: (String(itemID)))
		}
		.do(onNext: { [unowned self] _ in
			self.refresh()
		})

		deleteStudioItemResponse = deleteBrandAssetResponse
			.asDriver(onErrorJustReturn: Result.failure(StudioServiceError.canNotDeleteItem))

		let deleteBrandResp = deleteBrand
			.flatMapLatest { brandID in
				return studioService
					.deleteBrand(with: brandID)
		}
		.do(onNext: { [unowned self] _ in
			self.refresh()
		})

		deleteBrandResponse = deleteBrandResp
			.asDriver(onErrorJustReturn: Result.failure(StudioServiceError.canNotDeleteBrand))

		let currentSelectedBrandID = viewModelState
			.asObservable()
			.map { $0.currentBrandID }
			.compactMap { $0 }
			.map { String($0) }

		let uploadNewAsset = newStudioAssetUpload.asObservable()
			.withLatestFrom(currentSelectedBrandID) {data, brandID in return (data, brandID)}
			.map { data, string in
				return (data, Int(string))
		}
		.flatMapLatest { data, brandID in
			return studioService
				.uploadAsset(brandID: brandID, studioAsset: data)
		}
		.do(onNext: { [unowned self] _ in
			self.refresh()
		})

		uploadNewAssetResponse = uploadNewAsset
			.asDriver(onErrorJustReturn: Result.failure(StudioServiceError.canNotUploadAsset))
	}
}
