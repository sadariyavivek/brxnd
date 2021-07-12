//
//  RxNetworkingWrappers.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-18.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

// MARK: - Account
extension UserAPI: ReactiveCompatible {}

extension Reactive where Base == UserAPI {
	func getUserInfo() -> Single<Result<UserResponse, Error>> {
		return .create { single in
			self.base.getUserInfo(completion: { result in
				switch result {
				case .success:
					single(.success(result))
				case .failure(let failure):
					single(.success(Result.failure(failure)))
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension UserRegistrationAPI: ReactiveCompatible {}

extension Reactive where Base == UserRegistrationAPI {
	func signUp(_ username: String, _ email: String, _ password: String) -> Observable<Bool> {
		return .create { observer in
			self.base.signUp(username: username, email: email, password: password, completion: { result in
				switch result {
				case .success:
					observer.onNext(true)
					observer.onCompleted()
				case .failure:
					observer.onNext(false)
					observer.onCompleted()
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension Reactive where Base == UserRegistrationAPI {
	func facebookUserDataUpload(email: String, name: String,
								token: String, avatar: String? = nil) -> Observable<Result<BRXNDFBAccUploadResponse, Error>> {
		return .create { observer in
			self.base.facebookUserDataUpload(email: email, name: name, token: token, avatar: avatar, completion: { result in
				switch result {
				case .success(let response):
					observer.onNext(.success(response))
					observer.onCompleted()
				case .failure(let error):
					observer.onNext(.failure(error))
					observer.onCompleted()
				}
			})
			return Disposables.create { self.base.router.cancel() }
		}
	}
}

extension FacebookLoginManager: ReactiveCompatible {}

extension Reactive where Base == FacebookLoginManager {
	func profileDataRequest() -> Observable<Result<[String: Any], Error>> {
		return .create { observer in
			self.base.profileDataRequest(completion: { result in
				switch result {
				case .success(let dict):
					observer.onNext(.success(dict))
					observer.onCompleted()
				case .failure(let error):
					observer.onNext(.failure(error))
					observer.onCompleted()
				}
			})
			return Disposables.create { }
		}
	}
}

extension UserLoginAPI: ReactiveCompatible {}

extension Reactive where Base == UserLoginAPI {
	func signIn(email: String, password: String) -> Observable<Result<User, Error>> {
		return .create { observer in
			self.base.login(username: email, password: password, completion: { result in
				switch result {
				case .success(let user):
					observer.onNext(.success(User.newUser(networkData: user)))
					observer.onCompleted()
				case .failure(let error):
					observer.onNext(.failure(error))
					observer.onError(error)
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension UserValidationAPI: ReactiveCompatible {}

extension Reactive where Base == UserValidationAPI {
	func validate(validationType: UserValidation) -> Observable<Result<String, Error>> {
		return .create { observer in
			self.base.validate(userValidationType: validationType, completion: { result in
				switch result {
				case .success(let value):
					observer.onNext(.success(value))
					observer.onCompleted()
				case .failure(let error):
					observer.onNext(.failure(error))
					observer.onError(error)
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

// MARK: - Posts&Pages

extension PagesAPI: ReactiveCompatible {}

extension Reactive where Base == PagesAPI {
	func getPages() -> Observable<Result<[PostPage], Error>> {
		return .create { observer in
			self.base.getPages(completion: { result in
				switch result {
				case .success(let value):
					observer.onNext(.success(value))
					observer.onCompleted()
				case .failure(let error):
					observer.onNext(.failure(error))
					//					observer.onError(error)
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension PostsAPI: ReactiveCompatible {}

extension Reactive where Base == PostsAPI {
	func getPosts(for facebookPageID: PageID) -> Observable<Result<FBPosts, Error>> {
		return .create { observer in
			self.base.getPosts(for: facebookPageID, completion: { result in
				switch result {
				case .success(let value):
					observer.onNext(.success(value))
					observer.onCompleted()
				case .failure(let error):
					observer.onNext(.failure(error))
					//					observer.onError(error)
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
    
    func getPostsInsta() -> Observable<Result<InstaPosts, Error>> {
        return .create { observer in
            self.base.getPostsInsta { result in
                switch result {
                case .success(let value):
                    observer.onNext(.success(value))
                    observer.onCompleted()
                case .failure(let error):
                    observer.onNext(.failure(error))
                    //                    observer.onError(error)
                }
            }
            return Disposables.create {self.base.router.cancel()}
        }
    }
}

extension Reactive where Base == PostsAPI {
	func deletePost(for identifier: PostIdentifier) -> Single<Result<String, Error>> {
		return .create { single in
			self.base.deletePost(for: identifier, completion: { result in
				switch result {
				case .success:
					single(.success(result))
				case .failure(let error):
					single(.success(Result.failure(error)))
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension Reactive where Base == PostsAPI {
	func getNextPosts(for pageID: String, cursor: String) -> Single<Result<FBPostsPaginated, Error>> {
		return .create { single in
			self.base.getNextPosts(for: pageID,
								   cursor: cursor, completion: { result in
									switch result {
									case .success:
										single(.success(result))
									case .failure(let error):
										single(.success(Result.failure(error)))
									}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension Reactive where Base == PostsAPI {
	func newPost(with post: NewPost)
		-> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
			return .create { single in
				self.base.newPost(with: post, completion: { result in
					switch result {
					case .success:
						single(.success(result))
					case .failure(let error):
						single(.success(Result.failure(error)))
					}
				})
				///avoid cancelling the req in case of multiple (zipped) calls with the same base
				///used in PostingViewModel.
				//								return Disposables.create {self.base.router.cancel()}
				return Disposables.create {}
			}
	}
}

// MARK: - Scheduled Posts
extension ScheduledAPI: ReactiveCompatible {}

extension Reactive where Base == ScheduledAPI {
	func getScheduledPosts(for facebookPageID: PageID) -> Observable<Result<FBPostsScheduled, Error>> {
		return .create { observer in
			self.base.getScheduledPosts(for: facebookPageID, completion: { result in
				switch result {
				case .success(let value):
					observer.onNext(.success(value))
					observer.onCompleted()
				case .failure(let error):
					observer.onNext(.failure(error))
					//					observer.onError(error)
				}
			})
			///avoid cancelling the req in case of multiple (zipped) calls with the same base
			///used in ScheduleViewModel.
			//				return Disposables.create {self.base.router.cancel()}
			return Disposables.create { }
		}
	}
}

extension Reactive where Base == ScheduledAPI {
	func publishScheduledPostNow(for postIdentifier: PostIdentifier)
		-> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
			return .create { single in
				self.base.publishScheduledPostNow(for: postIdentifier, completion: { result in
					switch result {
					case .success:
						single(.success(result))
					case .failure(let error):
						single(.success(Result.failure(error)))
					}
				})
				return Disposables.create {self.base.router.cancel()}
			}
	}
}

// MARK: - Brand
extension BrandAPI: ReactiveCompatible {}

extension Reactive where Base == BrandAPI {
	func getBrands() -> Single<Result<BrandResponse, Error>> {
		return .create { single in
			self.base.getBrands(completion: { result in
				switch result {
				case .success:
					single(.success(result))
				case .failure(let error):
					single(.success(Result.failure(error)))
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension Reactive where Base == BrandAPI {
	func createNewBrand(name: String,
						description: String,
						color: String,
						isDraft: Bool,
						brandLogo: Data) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
		return .create { single in
			self.base.createNewBrand(name: name,
									 description: description,
									 color: color,
									 isDraft: isDraft,
									 brandLogo: brandLogo, completion: { result in
										switch result {
										case .success:
											single(.success(result))
										case .failure(let error):
											single(.success(Result.failure(error)))
										}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension Reactive where Base == BrandAPI {
	func deleteBrand(id: BrandID) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
		return .create { single in
			self.base.deleteBrand(id: id, completion: { result in
				switch result {
				case .success:
					single(.success(result))
				case .failure(let error):
					single(.success(Result.failure(error)))
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

// MARK: - Studio
extension StudioAPI: ReactiveCompatible {}

extension Reactive where Base == StudioAPI {
	func fetchBrandAssets(for brandID: String) -> Observable<Result<BrandAssets, Error>> {
		return .create { observer in
			self.base.fetchBrandAssets(for: brandID, completion: { result in
				switch result {
				case .success(let value):
					observer.onNext(.success(value))
					observer.onCompleted()
				case .failure(let error):
					observer.onNext(.failure(error))
					//					observer.onError(error)
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension Reactive where Base == StudioAPI {
	func fetchNextBrandAssets(for brandID: String,
							  lastAssetID: Int) -> Observable<Result<BrandAssets, Error>> {
		return .create { observer in
			self.base.fetchNextBrandAssets(for: brandID, lastAssetID: lastAssetID, completion: { result in
				switch result {
				case .success(let value):
					observer.onNext(.success(value))
					observer.onCompleted()
				case .failure(let error):
					observer.onNext(.failure(error))
					//					observer.onError(error)
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension Reactive where Base == StudioAPI {
	func delete(studioItem id: String) -> Single<Result<BRXNDCreateOrDeleteResponse, Error>> {
		return .create { single in
			self.base.delete(studioItem: id, completion: { result in
				switch result {
				case .success:
					single(.success(result))
				case .failure(let error):
					single(.success(Result.failure(error)))
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension Reactive where Base == StudioAPI {
	func uploadAsset(brandID: BrandID, studioAsset: Data) -> Single<Result<BRXNDStudioAssetUploadResponse, Error>> {
		return .create { single in
			self.base.uploadAsset(brandID: brandID, studioAsset: studioAsset, completion: { result in
				switch result {
				case .success:
					single(.success(result))
				case .failure(let error):
					single(.success(Result.failure(error)))
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

// MARK: - Editor
extension EditorAPI: ReactiveCompatible {}

extension Reactive where Base == EditorAPI {
	func getEditorSerializedData(id: ImageID) -> Single<Result<Data, Error>> {
		return .create { single in
			self.base.getEditorSerializedData(id: id, completion: { result in
				switch result {
				case .success:
					single(.success(result))
				case .failure(let error):
					single(.success(Result.failure(error)))
				}
			})
			return Disposables.create {self.base.router.cancel()}
		}
	}
}

extension Reactive where Base == EditorAPI {
	func saveEditorSerializedData(id: ImageID, studioAsset: StudioAssetTuple)
		-> Single<Result<BRXNDEditorUploadResponse, Error>> {
			return .create { single in
				self.base.saveEditorSerializedData(id: id, studioAsset: studioAsset, completion: { result in
					switch result {
					case .success:
						single(.success(result))
					case .failure(let error):
						single(.success(Result.failure(error)))
					}
				})
				return Disposables.create {self.base.router.cancel()}
			}
	}
}
