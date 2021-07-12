//
//  BrandsAPI.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-02-25.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

struct BrandAPI {
	let router = NetworkRouter<BrandAPIProvider>()
}


extension BrandAPI {
	func getBrands(completion: @escaping (Result<BrandResponse, Error>) -> Void ) {

		router.request(.fetchAllBrands) { (data, response, error) in

			if let err = error {
				completion(Result.failure(err))
				return
			}

			if let response = response as? HTTPURLResponse {

				let result = NetworkResponse.handleNetworkResponse(response)

				switch result {
				case .success:
					guard let data = data else { completion(Result.failure(NetworkResponse.noData))
						return
					}
					do {
						completion(Result.success(try BrandResponse(data: data)))
					} catch let err {
						completion(Result.failure(err))
					}
				case .failure(let networkFailureError):
					completion(Result.failure(networkFailureError))
				}
			}
		}
	}
    
    func getFBPages(completion: @escaping (Result<[FBPage], Error>) -> Void ) {

        router.request(.fetchFBpages) { (data, response, error) in

            if let err = error {
                completion(Result.failure(err))
                return
            }

            if let response = response as? HTTPURLResponse {

                let result = NetworkResponse.handleNetworkResponse(response)

                switch result {
                case .success:
                    guard let data = data else { completion(Result.failure(NetworkResponse.noData))
                        return
                    }
                    do {
                        let jsonDecoder = JSONDecoder()

                        let jsonCatalogs = try jsonDecoder.decode(Array<FBPage>.self,from: data)
                        completion(Result.success(jsonCatalogs))
//                        completion(Result.success(try FBPages(data: data).list))
                    } catch let err {
                        completion(Result.failure(err))
                    }
                case .failure(let networkFailureError):
                    completion(Result.failure(networkFailureError))
                }
            }
        }
    }
}

extension BrandAPI {
	func createNewBrand(name: String,
						description: String,
						color: String,
						isDraft: Bool,
						brandLogo: Data, completion: @escaping (Result<BRXNDCreateOrDeleteResponse, Error>) -> Void ) {

        print("===========")
        print(color)
        print("===========")
        
		router.request(.createNewBrand(name: name, description: description, color: color, isDraft: isDraft, brandLogo: brandLogo)) { data, response, error in
			if let err = error {
				completion(Result.failure(err))
				return
			}
			if let response = response as? HTTPURLResponse {

				let result = NetworkResponse.handleNetworkResponse(response)
				switch result {
				case .success:
                    
					guard let data = data else { completion(Result.failure(NetworkResponse.noData))
						return
					}
					do {
						completion(Result.success(try BRXNDCreateOrDeleteResponse(data: data)))
					} catch let err {
						completion(Result.failure(err))
					}
				case .failure(let networkFailureError):
					completion(Result.failure(networkFailureError))
				}
			}
		}
	}
}

extension BrandAPI {
	func deleteBrand(id: BrandID, completion: @escaping (Result<BRXNDCreateOrDeleteResponse, Error>) -> Void) {
		router.request(.deleteBrand(id: id)) { data, response, error in
			if let err = error {
				completion(Result.failure(err))
				return
			}
			if let response = response as? HTTPURLResponse {

				let result = NetworkResponse.handleNetworkResponse(response)
				switch result {
				case .success:
					guard let data = data else { completion(Result.failure(NetworkResponse.noData))
						return
					}
					do {
						completion(Result.success(try BRXNDCreateOrDeleteResponse(data: data)))
					} catch let err {
						completion(Result.failure(err))
					}
				case .failure(let networkFailureError):
					completion(Result.failure(networkFailureError))
				}
			}
		}
	}
}
