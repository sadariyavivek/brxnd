//
//  PostsCollectionView.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-02.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

final class PostsCollectionView: UICollectionView, BindableType {
	
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
		
		setupComponents()
		bindViewModel()
	}
	
	private func setupComponents() {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		self.refreshControl = refreshControl
	}
	
	@objc private func refresh() {
		viewModel.input.refresh()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func layout(superViewFrame: CGRect) -> UICollectionViewFlowLayout {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		
		layout.minimumInteritemSpacing = 20
		layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
		layout.itemSize = (CGSize(width: 0.95 * superViewFrame.width, height: 0.75 * superViewFrame.height))
		return layout
	}
	
	//	private func animateRefreshControl(in view: UIView?) {
	//		if let scrollView = view as? UIScrollView {
	//			scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height/8), animated: true)
	//		}
	//	}
	
	func bindViewModel() {
		
		let this = self
		
		let output = viewModel
			.output
		
		let input = viewModel
			.input

		let feedData = output
			.posts
			.asDriver()
			.map { posts -> [FeedData] in
				if posts == nil {
					return []
				} else {
					return posts?.posts.feed?.data ?? []
				}
		}

		feedData
			.drive(rx.items(cellIdentifier: PostsCellConstants.postsReuseIdentifier,
							cellType: PostsCollectionViewXibCell.self)) { (_, item, cell) in
								cell.configure(with: item)
		}.disposed(by: disposeBag)

		feedData
			.debounce(.seconds(1))
			.drive(onNext: { [weak self] data in
				if data.isEmpty {
					self?.handleEmptyState()
				} else {
					if self?.backgroundView != nil {
						self?.restore()
					}
				}
			}).disposed(by: disposeBag)

		this
			.rx
			.reachedBottom()
			.skipUntil(output.isRefreshing.asObservable())
			.bind(to: input.loadMorePosts)
			.disposed(by: disposeBag)

		let refControl = refreshControl!
		
		output
			.isRefreshing
			.drive(refControl.rx.isRefreshing)
			.disposed(by: disposeBag)
		
		//		output
		//			.isRefreshing
		//			.distinctUntilChanged()
		//			.drive(onNext: { [weak self] in
		//				if $0 {self?.animateRefreshControl(in: self)}
		//			}).disposed(by: disposeBag)
		//
		this
			.rx
			.modelSelected(FeedData.self)
			.asControlEvent()
			.bind(to: input.postSelectedAction.inputs)
			.disposed(by: disposeBag)
	}

	private func handleEmptyState() {
		setEmptyView(title: "No posts yet ;(",
					 message: "",
					 messageImage: BRXNDImages.libraryPlaceHolder)
	}
	
	//	func animation() {
	//		let this = self
	//
	//		this
	//			.rx
	//			.willDisplayCell
	//			.observeOn(MainScheduler.instance)
	//			.subscribe(onNext: ({ (cell, _) in
	//				cell.alpha = 0
	//				let transform = CATransform3DTranslate(CATransform3DIdentity, 0, -250, 0)
	//				cell.layer.transform = transform
	//				UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
	//					cell.alpha = 1
	//					cell.layer.transform = CATransform3DIdentity
	//				}, completion: nil)
	//			})).disposed(by: disposeBag)
	//	}
}
