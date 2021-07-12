//
//  ScheduledTableViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-10-24.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Nuke
import RxDataSources
import EmptyStateKit

private struct ScheduleCellConstants {
	static let scheduleCell: String = "ScheduledTableViewCell"
}

final class ScheduledTableViewController: UIViewController,
	ScheduledView,
	BindableType {
	
	var viewModel: ScheduledViewModelType!
	var dataSource: RxTableViewSectionedAnimatedDataSource<PostSection>!

	@IBOutlet var tableView: UITableView!

	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()

		setupComponents()
		configureDataSource()
		bindViewModel()

		tableView
			.rx
			.setDelegate(self)
			.disposed(by: disposeBag)

		self.view.emptyState.delegate = self
	}

	private func setupUI() {
		setTitles(navigationTitle: "Scheduled posts", tabBarTitle: "Scheduled")

		navigationItem.rightBarButtonItem?.tintColor = .black
		navigationItem.leftBarButtonItem?.tintColor = .black
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.black,
			NSAttributedString.Key.font: BRXNDFonts.sourceSansProsemiBold13
		]

	}

	private func setupComponents() {

		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80

		tableView.tableFooterView = UIView()

		let nib = UINib(nibName: "ScheduleHeader", bundle: nil)
		tableView.register(nib, forHeaderFooterViewReuseIdentifier: ScheduledTableViewHeaderFooterView.reuseIdentifier)

		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		self.tableView.refreshControl = refreshControl
	}
	@objc private func refresh() {
		viewModel.input.refresh()
	}
	
	func bindViewModel() {

		let input = viewModel
			.input

		let this = self

		let output = viewModel
			.output

		output
			.postSections
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)

		let refControl = self.tableView.refreshControl!

		output
			.isRefreshing
			.drive(refControl.rx.isRefreshing)
			.disposed(by: disposeBag)

		this
			.tableView
			.rx
			.modelSelected(FeedData.self)
			.asControlEvent()
			.bind(to: input.postSelectedAction.inputs)
			.disposed(by: disposeBag)

		this
			.rx
			.methodInvoked(#selector(viewDidAppear(_:)))
			.map { _ in }
			.bind(to: input.viewDidAppearTrigger)
			.disposed(by: disposeBag)

		output
			.error
			.filter { $0 != nil }
			.drive(onNext: { [weak self] error in
				if let error = error {
					if case ScheduleServiceError.notLoggedInSocialMedia = error {
						self?.view.emptyState.format = BRXNDEmptyState.socialMediaFormat()
						self?.view.emptyState.show(BRXNDEmptyState.notLoggedInSocialMedia)
					} else {
						self?.presentAlertWithTitle(title: "Error",
													message: "\(error.localizedDescription)",
													options: "Ok", completion: { _ in })
					}
				} else {
					self?.view.emptyState.hide()
				}
			}).disposed(by: disposeBag)

	}

	private func configureDataSource() {
		dataSource = RxTableViewSectionedAnimatedDataSource<PostSection>(
			configureCell: {  _, tableView, indexPath, feedData in
				let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCellConstants.scheduleCell,
														 for: indexPath) as! ScheduledTableViewCell
				cell.configureCell(with: feedData)
				return cell
		})
	}
}

extension ScheduledTableViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let header = self.tableView.dequeueReusableHeaderFooterView(
			withIdentifier: ScheduledTableViewHeaderFooterView.reuseIdentifier) as! ScheduledTableViewHeaderFooterView

		header.pageTitle.text = dataSource[section].model.name

		if let url = URL(string: dataSource[section].model.picture.url) {
			let req = ImageRequest(url: url, processors: [
				ImageProcessor.Resize(size: CGSize(width: 50, height: 50)),
				ImageProcessor.Circle()
			])
			Nuke.loadImage(with: req, into: header.pageImageView)
		}
		return header
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 80
	}
}

extension ScheduledTableViewController: EmptyStateDelegate {
	func emptyState(emptyState: EmptyState, didPressButton button: UIButton) {
		let input = viewModel.input
		input.logInSocialMediaAction.execute()
	}
}
