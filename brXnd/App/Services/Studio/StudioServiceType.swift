//
//  StudioServiceType.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

enum StudioServiceError: Error {
	case empty
	case emptyBrands
	case emptyStudio
	case unknownBrand

	case canNotDeleteItem
	case canNotDeleteBrand

	case canNotCreateBrand
	case canNotUploadAsset
}

extension StudioServiceError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .empty, .emptyBrands, .emptyStudio:
			return "Empty response from the server"
		case .unknownBrand:
			return "Please choose a brand first!"
		case .canNotDeleteItem, .canNotDeleteBrand:
			return "Issue while deleting"
		case .canNotUploadAsset, .canNotCreateBrand:
			return "Issue while uploading"
		}
	}
}

protocol StudioServiceType {

	func fetchBrandAssets(for brandID: String) -> Observable<Result<BrandAssets, Error>>

	func fetchNextBrandAssets(for brandID: String, lastAssetID: Int) -> Observable<Result<BrandAssets, Error>>

	func delete(studioItem id: String) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>>

	func uploadAsset(brandID: BrandID?, studioAsset: Data) -> Single<Result<BRXNDStudioAssetUploadResponse, Error>>
}

protocol BrandServiceType {

	func fetchBrands() -> Single<Result<BrandResponse, Error>>

	func deleteBrand(with id: BrandID) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>>

	func createNewBrand(name: String,
						description: String,
						color: String,
						isDraft: Bool,
						brandLogo: Data) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>>
}
