//
//  FreeFunc.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-29.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

// MARK: - Free functions

public func extractSuccess<T>(_ result: Result<T, Error>) -> T? {
	if case let .success(search) = result {
		return search
	} else {
		return nil
	}
}
