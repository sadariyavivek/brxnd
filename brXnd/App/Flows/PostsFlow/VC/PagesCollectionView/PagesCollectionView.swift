//
//  PagesCollectionView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-28.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class PagesCollectionView: UICollectionView, BindableType {

	var viewModel: PostsViewModelType!
	
	private let disposeBag = DisposeBag()

	override init(frame: CGRect,
				  collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
	}

	convenience init(frame: CGRect,
					 collectionViewLayout layout: UICollectionViewLayout,
					 viewModel: PostsViewModelType) {
		self.init(frame: frame, collectionViewLayout: layout)
		self.showsVerticalScrollIndicator = false
		self.showsHorizontalScrollIndicator = false
		self.viewModel = viewModel

		bindViewModel()
		rx.setDelegate(self).disposed(by: disposeBag)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	static func layout(superViewFrame: CGRect) -> UICollectionViewFlowLayout {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = CGSize(width: 90, height: 90)
		return layout
	}

	internal func bindViewModel() {

		let this = self

		let output = viewModel
			.output

		let input = viewModel
			.input

		output
			.pages
			.drive(rx.items(cellIdentifier: PostsCellConstants.pagesReuseIdentifier,
							cellType: PagesCollectionViewCell.self)) { (_, item, cell) in
								cell.configure(with: item)
		}.disposed(by: disposeBag)

		this
			.rx
			.modelSelected(PostPage.self)
			.subscribe(onNext: { page in
				input.pageSelected.accept(page.id)
				input.refresh()
			}).disposed(by: disposeBag)
	}
}

extension PagesCollectionView: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

		// Make sure that the number of items is worth the computing effort.
		guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
			let dataSourceCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
			dataSourceCount > 0 else {
				return .zero
		}
		let cellCount = CGFloat(dataSourceCount)
		let itemSpacing = flowLayout.minimumInteritemSpacing
		let cellWidth = flowLayout.itemSize.width + itemSpacing
		var insets = flowLayout.sectionInset

		// Make sure to remove the last item spacing or it will
		// miscalculate the actual total width.
		let totalCellWidth = (cellWidth * cellCount) - itemSpacing
		let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right

		// If the number of cells that exist take up less room than the
		// collection view width, then center the content with the appropriate insets.
		// Otherwise return the default layout inset.
		guard totalCellWidth < contentWidth else {
			return insets
		}

		// Calculate the right amount of padding to center the cells.
		let padding = (contentWidth - totalCellWidth) / 2.0
		insets.left = padding
		insets.right = padding
		return insets
	}
}
