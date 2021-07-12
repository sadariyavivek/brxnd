//
//  NewBrandViewModel.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-09.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Action

enum BrandSaveType {
	case asDraft
	case defaultBrand
}

extension BrandSaveType {
	func asBool() -> Bool {
		switch self {
		case .asDraft:
			return true
		case .defaultBrand:
			return false
		}
	}
}

protocol NewBrandViewModelCoordinator: class {
	var onDismiss: ((_ success: Bool) -> Void)? { get set }
}

protocol NewBrandViewModelInput {
	var dismissAction: Action<Bool, Void> { get }

	var logoImage: BehaviorRelay<UIImage?> { get }
	var brandName: PublishRelay<String> { get }
	var brandDescription: PublishRelay<String> { get }
    var brandColor: PublishRelay<String> { get }
	var saveTap: PublishRelay<BrandSaveType> { get }
}

protocol NewBrandViewModelOutput {
	var logoImageDriver: Driver<UIImage?> { get }
	var isLoading: Driver<Bool> { get }
	var isSaveEnabled: Driver<Bool> { get }
	var saveResult: Driver<Result<BRXNDCreateOrDeleteResponse, Error>>! { get }
}

protocol NewBrandViewModelType {
	var input: NewBrandViewModelInput { get }
	var output: NewBrandViewModelOutput { get }
	var coordinator: NewBrandViewModelCoordinator { get }
}

final class NewBrandViewModel:
NewBrandViewModelInput,
NewBrandViewModelOutput,
NewBrandViewModelType,
NewBrandViewModelCoordinator {

	var input: NewBrandViewModelInput { return self }
	var output: NewBrandViewModelOutput { return self }
	var coordinator: NewBrandViewModelCoordinator { return self }

	// MARK: - Coordinator
	var onDismiss: ((_ success: Bool) -> Void)?

	// MARK: - Input
	var logoImage 			=	BehaviorRelay<UIImage?>(value: nil)
	var brandName 			=	PublishRelay<String>()
	var brandDescription 	=	PublishRelay<String>()
    var brandColor          =   PublishRelay<String>()
    var saveTap				=	PublishRelay<BrandSaveType>()
    var slcFBPages                =    PublishRelay<Array<Any>>()

	// MARK: - Output
	var logoImageDriver: Driver<UIImage?>
	var isLoading: Driver<Bool>
	var isSaveEnabled: Driver<Bool>
	var saveResult: Driver<Result<BRXNDCreateOrDeleteResponse, Error>>!

	// MARK: - Action
	lazy var dismissAction: Action<Bool, Void> = {
		return Action<Bool, Void> { [unowned self] value in
			self.onDismiss?(value)
			return Observable.just(())
		}
	}()

	// MARK: - Private
	private let api: BrandServiceType

	init(api: BrandServiceType = StudioService()) {
		self.api = api
		self.logoImageDriver = logoImage.asDriver()

		///validation
		let validatedBrandName = brandName
			.map { $0.count >= 3 && $0.count < 20 ? true : false }

		let validatedBrandDescription = brandDescription
			.map { $0.count >= 3 && $0.count < 50 ? true : false }
        
//        let validatedBrandColor = brandColor
//        .map { $0 != "Select Brand color" ? true : false }

        let validatedBrandColor = brandColor
            .map { _ in true }
        
		let validatedImage = logoImage
			.map { $0 != nil ? true : false }

		self.isSaveEnabled = Observable.combineLatest(
			validatedBrandName,
			validatedBrandDescription,
			validatedImage,
            validatedBrandColor
        ) { (name: Bool, description: Bool, image: Bool , color: Bool) -> Bool in
			return name && description && image && color
			}
			.asDriver(onErrorJustReturn: false)
			.startWith(false)

		let loadingIndicator = RxActivityIndicator()
		self.isLoading = loadingIndicator.asDriver()

		let saved = Observable.combineLatest(brandName.asObservable(),
											 brandDescription.asObservable(),
											 logoImage.asObservable().unwrap(),
                                             brandColor.asObservable(),
                                             saveTap.asObservable()) {(name: $0, description: $1, image: $2, color: $3, tapType: $4)}

		let errorImg = UIImage(named: "brxndBrandsLogo")!
            .jpegData(compressionQuality: 0.1)
        
		saveResult = saveTap
			.withLatestFrom(saved)
			.flatMapLatest {
				return api
					.createNewBrand(name: $0.name,
									description: $0.description,
                                    color: $0.color,
									isDraft: $0.tapType.asBool(),
                                    brandLogo: $0.image.jpegData(compressionQuality: 0.1) ?? errorImg!)

                    
					.observeOn(MainScheduler.instance)
					.trackActivity(loadingIndicator)
			}
			.do(onNext: { [unowned self] result in
				switch result {
				case .success:
					self.onDismiss?(true)
				default:
					break
				}
			})
			.asDriver(onErrorJustReturn: Result.failure(StudioServiceError.canNotCreateBrand))
	}
}
