//
//  StudioAssetsCollectionView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-30.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import RxGesture

final class StudioItemCollectionView: UICollectionView, BindableType {

	var onItemDeleteAlert: ((CellID) -> Void)?

	var viewModel: StudioViewModelType!

	// MARK: - Private
	private lazy var itemSizeCache: [IndexPath: CGFloat] = [:]
	private let disposeBag = DisposeBag()

	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	convenience init(frame: CGRect,
					 collectionViewLayout layout: UICollectionViewLayout,
					 viewModel: StudioViewModelType) {
		self.init(frame: frame, collectionViewLayout: layout)

		self.showsVerticalScrollIndicator = false
		self.showsHorizontalScrollIndicator = false
		self.viewModel = viewModel

		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		self.refreshControl = refreshControl

		bindViewModel()

		if let layout = self.collectionViewLayout as? PinterestStyleLayout { layout.delegate = self }
	}

	internal func bindViewModel() {

		let this = self

		let output = viewModel
			.output
		let input = viewModel
			.input

		let studioItems = output
			.studioItems

		studioItems
			.drive(rx.items(cellIdentifier: StudioCellConstants.studioReuseIdentifier,
							cellType: StudioItemCollectionViewCell.self)) { (_, item, cell) in
								cell.configure(with: item)
		}.disposed(by: disposeBag)

		studioItems
			.debounce(.seconds(1))
			.drive(onNext: {[weak self] assets in
				if assets.isEmpty {
					self?.handleEmptyState()
				} else {
					if self?.backgroundView != nil {
						self?.restore()
					}
				}
			}).disposed(by: disposeBag)

		let refControl = refreshControl!

		output
			.isRefreshing
			.drive(refControl.rx.isRefreshing)
			.disposed(by: disposeBag)

		let isRefreshingObservable = output
			.isRefreshing
			.distinctUntilChanged()
			.asObservable()

		let studioItemsObservable = studioItems
			.asObservable()

		let zipped = Observable.zip(isRefreshingObservable, studioItemsObservable)

		zipped
			.asDriver(onErrorJustReturn: (false, []))
			.drive(onNext: { [weak self] isRefreshing, studio in
				if isRefreshing { self?.animateRefreshControl(in: self)} else if !isRefreshing && !studio.isEmpty { self?.restore() }
			}).disposed(by: disposeBag)

		this
			.rx
			.reachedBottom()
			.skipUntil(output.isRefreshing.asObservable())
			.bind(to: input.loadMoreStudioItems)
			.disposed(by: disposeBag)

		this
			.rx
			.longPressGesture()
			.when(.began)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] location in
				guard let selected = self?.indexPathForItem(at: location.location(in: self)),
					let cell = self?.getCell(for: selected) as? StudioItemCollectionViewCell,
					let id = cell.cellItemID else { return }
				self?.onItemDeleteAlert?(id)
			}).disposed(by: disposeBag)

		let indexPath = this
			.rx
			.itemSelected

		let model = this
			.rx
			.modelSelected(BrandAsset.self)

		Observable.zip(indexPath, model) { (indexPath: $0, model: $1)}
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { [weak self] pair in
				guard 	let cell = self?.getCell(for: pair.indexPath) as? StudioItemCollectionViewCell,
					let imageFromCell = cell.imageView.image else { return }
				
				var asset: PhotoMediaItem
				if pair.model.isEditorDataAvailable() {
					asset = PhotoMediaItem(image: imageFromCell, mediaModifiers: .isEdited(nil), assetModel: pair.model)
				} else {
					asset = PhotoMediaItem(image: imageFromCell, mediaModifiers: .isOriginal(fromCamera: nil), assetModel: pair.model)
				}
				self?.viewModel.input.itemSelectedAction.execute(asset)
			})
			.disposed(by: disposeBag)
	}

	@objc private func refresh() {
		viewModel.input.refresh()

		//removes empty - state view
		if self.backgroundView != nil {
			self.restore()
		}
	}

	private func handleEmptyState() {
		setEmptyView(title: "Hello there,",
					 message: "Start getting creative now!",
					 messageImage: BRXNDImages.libraryPlaceHolder)
	}

	private func animateRefreshControl(in view: UIView?) {
		if let scrollView = view as? UIScrollView {
			scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height/8), animated: true)
		}
	}
}

extension StudioItemCollectionView: PinterestStyleLayoutDelegate {
	func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {

		if let itemSize = itemSizeCache[indexPath] {
			return itemSize
		} else {
			let randomValue = CGFloat.random(in: 150...350)
			itemSizeCache.updateValue(randomValue, forKey: indexPath)
			return randomValue
		}
	}

	private func redrawCustomLayout() {
		self.collectionViewLayout.invalidateLayout()
		self.reloadData()
	}
}
