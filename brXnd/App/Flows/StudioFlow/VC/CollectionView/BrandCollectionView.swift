//
//  BrandCollectionView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import RxGesture

final class BrandCollectionView: UICollectionView, BindableType {

	var onBrandDeleteAlert: ((CellID) -> Void)?

	var viewModel: StudioViewModelType!

	private let disposeBag = DisposeBag()

	override init(frame: CGRect,
				  collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
	}

	convenience init(frame: CGRect,
					 collectionViewLayout layout: UICollectionViewLayout,
					 viewModel: StudioViewModelType) {
		self.init(frame: frame, collectionViewLayout: layout)
		self.showsVerticalScrollIndicator = false
		self.showsHorizontalScrollIndicator = false
		self.viewModel = viewModel
		bindViewModel()

		allowsMultipleSelection = false

		rx.setDelegate(self).disposed(by: disposeBag)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	internal func bindViewModel() {

		let this = self

		let output = viewModel
			.output

		let input = viewModel
			.input

		let brands = output
			.brands

		let addButton
			= [BrandData(id: BRXNDMock.brand.id,
						 userID: BRXNDMock.brand.id,
						 name: "Add Brand",
						 datumDescription: nil,
						 logoPath: nil,
						 logo: nil,
						 slug: nil,
						 color: nil,
						 draft: nil,
						 createdAt: nil,
						 updatedAt: nil)]

		let addButtonObservable = Driver.just(addButton)

		let brandDataSource = brands
			.startWith([])

		let brandsGroup = Driver.combineLatest(addButtonObservable, brandDataSource) { $1 + $0 }

		brandsGroup
			.drive(rx.items(cellIdentifier: StudioCellConstants.brandReuseIdentifier,
							cellType: BrandCollectionViewXibCell.self)) { (_, item, cell) in
								cell.configure(with: item)
			}.disposed(by: disposeBag)

		this
			.rx
			.modelSelected(BrandData.self)
			.bind(to: input.selectedBrand)
			.disposed(by: disposeBag)
		
		this
			.rx
			.longPressGesture()
			.when(.began)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] location in
				guard let selected = self?.indexPathForItem(at: location.location(in: self)),
					let cell = self?.getCell(for: selected) as? BrandCollectionViewXibCell,
					let id = cell.brandID else { return }
				self?.onBrandDeleteAlert?(id)
			}).disposed(by: disposeBag)
	}
}

extension BrandCollectionView: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 90, height: self.bounds.height)
	}
}
