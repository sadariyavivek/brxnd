//
//  ItemModuleFactory.swift
//  CoordinatorImplementation
//
//  Created by Andrian Sergheev on 2019-02-15.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol StudioModuleFactory {
	func makeItemModule() -> (StudioContainerView, StudioViewModelType)
	func makeBrandCreationModule() -> (NewBrandView, NewBrandViewModelType)
}
