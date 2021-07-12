//
//  UIScrollView+rx.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-31.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension Reactive where Base: UIScrollView {
	func reachedBottom(withOffset offset: CGFloat = 0.0) -> Observable<Bool> {
		let observable = contentOffset
			.map { [weak base] contentOffset -> Bool in
				guard let scrollView = base else { return false}
				let visibleHeight = scrollView.frame.height
					- scrollView.contentInset.top
					- scrollView.contentInset.bottom
				let yAxis = contentOffset.y + scrollView.contentInset.top
				let threshold = max(offset, scrollView.contentSize.height - visibleHeight)
				return yAxis > threshold
		}
		return observable.distinctUntilChanged()
	}
}
