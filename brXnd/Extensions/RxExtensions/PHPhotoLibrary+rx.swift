//
//  PHPhotoLibrary+rx.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-03-12.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//
import Photos

extension PHPhotoLibrary {
	static var authorized: Observable<Bool> {
		return Observable.create { observer in
			DispatchQueue.main.async {
				if authorizationStatus() == .authorized {
					observer.onNext(true)
					observer.onCompleted()
				} else {
					observer.onNext(false)
					requestAuthorization { newStatus in
						observer.onNext(newStatus == .authorized)
						observer.onCompleted()
					}
				}
			}
			return Disposables.create()
		}
	}
}
