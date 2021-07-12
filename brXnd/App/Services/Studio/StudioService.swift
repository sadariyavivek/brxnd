//
//  StudioService.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct StudioService: BrandServiceType & StudioServiceType {

	private let brandAPI: BrandAPI
	private let studioAPI: StudioAPI
	
	init(brandAPI: BrandAPI = BrandAPI(), studioAPI: StudioAPI = StudioAPI()) {
		self.brandAPI = brandAPI
		self.studioAPI = studioAPI
	}

	func fetchBrands() -> Single<Result<BrandResponse, Error>> {
		return brandAPI
			.rx
			.getBrands()
			.retry(1)
			.timeout(.seconds(5), scheduler: MainScheduler.instance)
			.map { result in
				switch result {
				case .success(let value):
					if value.brands?.data?.first?.id != nil ,
						let brands = value.brands?.data {
						if !brands.isEmpty {
							return result
						} else {
							return Result.failure(StudioServiceError.emptyBrands)
						}
					} else {
						return Result.failure(StudioServiceError.emptyBrands)
					}
				case .failure(let failure):
					return Result.failure(failure)
				}
		}
	}

	//	func fetchBrands() -> Single<Result<BrandResponse, Error>> {
	//		return brandAPI
	//			.rx
	//			.getBrands()
	//			.retry(1)
	//			.timeout(.seconds(5), scheduler: MainScheduler.instance)
	//
	//	}

	func deleteBrand(with id: BrandID) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
		return brandAPI
			.rx
			.deleteBrand(id: id)
			.retry(1)
			.timeout(.seconds(10), scheduler: MainScheduler.instance)
			.flatMap { result in
				switch result {
				case .failure:
					return Single.just(.failure(StudioServiceError.canNotDeleteBrand))
				case .success:
					return Single.just(result)
				}
		}
	}
	func createNewBrand(name: String, description: String,color: String, isDraft: Bool, brandLogo: Data) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
		return brandAPI
			.rx
			.createNewBrand(name: name, description: description, color: color, isDraft: isDraft, brandLogo: brandLogo)
			.retry(1)
			.timeout(.seconds(30), scheduler: MainScheduler.instance)
			.flatMap { result in
				switch result {
				case .success:
					return Single.just(result)
				case .failure:
					return Single.just(.failure(StudioServiceError.canNotCreateBrand))
				}
		}
	}
	func fetchBrandAssets(for brandID: String) -> Observable<Result<BrandAssets, Error>> {
		return studioAPI
			.rx
			.fetchBrandAssets(for: brandID)
			.retry(1)
			.timeout(.seconds(10), scheduler: MainScheduler.instance)
			.map { result in
				switch result {
				case .success(let value):
					if let assets = value.media {
						if assets.isEmpty { return Result.failure(StudioServiceError.emptyStudio) } else { return Result.success(value) }
					} else {
						return Result.failure(StudioServiceError.emptyStudio)
					}
				case .failure(let failure):
					return Result.failure(failure)
				}
		}
	}
	
	func fetchNextBrandAssets(for brandID: String,
							  lastAssetID: Int) -> Observable<Result<BrandAssets, Error>> {
		return studioAPI
			.rx
			.fetchNextBrandAssets(for: brandID,
								  lastAssetID: lastAssetID)
			.retry(1)
			.timeout(.seconds(10), scheduler: MainScheduler.instance)
	}
	
	func delete(studioItem id: String) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
		return studioAPI
			.rx
			.delete(studioItem: id)
			.retry(1)
			.timeout(.seconds(10), scheduler: MainScheduler.instance)
			.flatMap { result in
				switch result {
				case .failure:
					return Single.just(Result.failure(StudioServiceError.canNotDeleteItem))
				case .success:
					return Single.just(result)
				}
		}
	}
	func uploadAsset(brandID: BrandID?, studioAsset: Data) -> Single<Result<BRXNDStudioAssetUploadResponse, Error>> {

		guard let id = brandID else { return Single.just(Result.failure(StudioServiceError.unknownBrand))}

		return studioAPI
			.rx
			.uploadAsset(brandID: id, studioAsset: studioAsset)
			.retry(1)
			.timeout(.seconds(10), scheduler: MainScheduler.instance)
			.flatMap { result in
				switch result {
				case .failure:
					return Single.just(Result.failure(StudioServiceError.canNotUploadAsset))
				case .success:
					return Single.just(result)
				}
		}
	}
}
