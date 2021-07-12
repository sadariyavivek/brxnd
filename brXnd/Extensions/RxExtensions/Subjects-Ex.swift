//
//  Subjects-Ex.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-09-11.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

extension PublishRelay {
	func asSignalEmptyError() -> Signal<Element> {
		return self.asObservable().asSignal(onErrorSignalWith: .empty())
	}
}

extension BehaviorRelay {
	func asSignalEmptyError() -> Signal<Element> {
		return self.asObservable().asSignal(onErrorSignalWith: .empty())
	}
}
