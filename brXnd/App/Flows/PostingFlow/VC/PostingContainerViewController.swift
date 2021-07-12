//
//  PostingContainerViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-11-13.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Former
import NVActivityIndicatorView

final class PostingContainerViewController: UIViewController,
	PostingView,
	NVActivityIndicatorViewable,
	BindableType {

	var viewModel: PostingViewModelType!

	@IBOutlet weak var tableView: UITableView!

	private lazy var former: Former = Former(tableView: self.tableView)
	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupForm()
		bindViewModel()
		setupComponents()

		///disable the interactive dismissal of presented view controller in iOS 13
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		} else {
			//
		}
	}

	private func setupUI() {
		self.tableView.separatorStyle = .none
		self.tableView.showsVerticalScrollIndicator = false
		self.tableView.showsHorizontalScrollIndicator = false

		self.view.backgroundColor = BRXNDColors.veryLightBlue
		self.tableView.backgroundColor = BRXNDColors.veryLightBlue
	}

	func bindViewModel() {
		let output = viewModel
			.output

		let input = viewModel
			.input
		
		output
			.isUpdating
			.drive(onNext: { [weak self] updating in
				if updating { self?.animateLoading() } else { self?.stopAnimating() }
			}).disposed(by: disposeBag)

		output
			.publishResponse
			.debounce(.seconds(1))
			.filter { $0 != nil }
			.drive(onNext: { [weak self] response in
				self?.presentAlertWithTitle(title: "Success!",
											message: response?.msgBody ?? "Uploaded!",
											options: "Ok",
											completion: { _ in input.onCloseTapAction.execute() })
			}).disposed(by: disposeBag)

		output
			.error
			.debounce(.seconds(1))
			.filter { $0 != nil }
			.drive(onNext: { [weak self] error in
				self?.presentAlertWithTitle(title: "Error",
											message: error?.localizedDescription ?? "",
											options: "Ok",
											completion: { _ in input.onCloseTapAction.execute() })
			}).disposed(by: disposeBag)
	}

	private func setupComponents() {

		let input = viewModel
			.input

		let output = viewModel
			.output

		var rightBarButtonItem = UIBarButtonItem(title: "Close",
												 style: .plain,
												 target: self,
												 action: nil)
		var attributes = [NSAttributedString.Key: AnyObject]()
		attributes[.foregroundColor] = UIColor.red
		rightBarButtonItem.setTitleTextAttributes(attributes,
												  for: [.normal])

		rightBarButtonItem.setTitleTextAttributes([ NSAttributedString.Key.foregroundColor: UIColor.red,
													NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		], for: .normal)
		rightBarButtonItem.setTitleTextAttributes([ NSAttributedString.Key.foregroundColor: UIColor.red,
													NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		], for: .selected)
		rightBarButtonItem.setTitleTextAttributes([ NSAttributedString.Key.foregroundColor: UIColor.gray,
													NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		], for: .disabled)

		navigationItem.rightBarButtonItem = rightBarButtonItem

		rightBarButtonItem
			.rx
			.action = input.onCloseTapAction

		var publishNowBarButtonItem = UIBarButtonItem(title: "Publish",
													  style: .done,
													  target: self,
													  action: nil)

		publishNowBarButtonItem.setTitleTextAttributes([ NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
														 NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		], for: .normal)
		publishNowBarButtonItem.setTitleTextAttributes([ NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
														 NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		], for: .selected)
		publishNowBarButtonItem.setTitleTextAttributes([ NSAttributedString.Key.foregroundColor: UIColor.gray,
														 NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 13)!
		], for: .disabled)

		navigationItem.leftBarButtonItems = [publishNowBarButtonItem]

		output
			.isPublishButtonEnabled
			.drive(publishNowBarButtonItem.rx.isEnabled)
			.disposed(by: disposeBag)

		publishNowBarButtonItem
			.rx
			.action = input.onPublishTapAction

	}

	// MARK: - Form
	private func setupForm() {

		let input = viewModel
			.input

		let output = viewModel
			.output

		//social media
		let facebookRow = CheckRowFormer<SocialMediaFormTableViewCell>(instantiateType: .Nib(nibName: SocialMediaFormTableViewCell.className)) {
			$0.formTitleLabel()?.text = "Facebook"
		}.configure {
			$0.rowHeight = 40
			$0.cell.cornerRadius = 8
			$0.cell.clipsToBounds = true
			$0.cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		}.onCheckChanged {
			input.facebookSelected.accept($0)
		}

		let instagramRow = CheckRowFormer<SocialMediaFormTableViewCell>(instantiateType: .Nib(nibName: SocialMediaFormTableViewCell.className)) {
			$0.formTitleLabel()?.text = "Instagram(coming soon...)"
			$0.isUserInteractionEnabled = false
			$0.formTitleLabel()?.alpha = 0.5
		}.configure {
			$0.rowHeight = 40
			$0.cell.cornerRadius = 8
			$0.cell.clipsToBounds = true
			$0.cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			$0.enabled = false
			$0.rowHeight = 40
		}.onCheckChanged { _ in

		}

		// text
		let textRow = TextViewRowFormer<FormTextViewCell> { [weak self] in
			$0.textView.textColor = UIColor.black
			if let `self` = self {
				$0.textView
					.rx
					.text
					.orEmpty
					.bind(to: input.messageTextField)
					.disposed(by: self.disposeBag)
			}
			//			$0.textView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
		}.configure {
			$0.cell.cornerRadius = 8
			$0.cell.clipsToBounds = true
			$0.placeholder = "Add your post message here!"
		}.onTextChanged { _ in }

		// media
		let mediaRow = CustomRowFormer<MediaFormTableViewCell>(instantiateType: .Nib(nibName: MediaFormTableViewCell.className)) { [weak self] in
			if let `self` = self,
				let imageView = $0.imageView {
				output
					.media
					.drive(imageView.rx.image)
					.disposed(by: self.disposeBag)
			}
		}.configure {
			$0.rowHeight = 300
//			$0.cell.cornerRadius = 8
//			$0.cell.clipsToBounds = true
			$0.cell.backgroundColor = BRXNDColors.veryLightBlue
		}.onSelected { _ in }

		// scheduled
		let scheduledSwitchRow = SwitchRowFormer<FormSwitchCell> {
			$0.titleLabel.text = "Scheduled"
			//			$0.titleLabel.textColor = .formerColor()
			$0.titleLabel.font = .boldSystemFont(ofSize: 16)
			//			$0.switchButton.onTintColor = .formerSubColor()
		}.configure {
			$0.cell.cornerRadius = 8
						$0.cell.clipsToBounds = true
						$0.cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		}

		let socialMediaSection = SectionFormer(rowFormers: [facebookRow, instagramRow])
			.set(headerViewFormer: createHeader("Select social media"))

		let textSection = SectionFormer(rowFormer: textRow)
			.set(headerViewFormer: createHeader("Write your message"))

		let mediaSection = SectionFormer(rowFormer: mediaRow)
			.set(headerViewFormer: createHeader("Attached media"))

		let scheduledSection = SectionFormer(rowFormer: scheduledSwitchRow)
			.set(headerViewFormer: createHeader("Schedule time"))

		scheduledSwitchRow
			.onSwitchChanged { [weak self] in
				if let `self` = self, let last = scheduledSection.lastRowFormer {
					self.toggleScheduledRow(shouldToggle: $0,
											sectionBottom: last,
											in: self.former,
											with: self.scheduledDatePickerRow)
				}
				input.isPostScheduled.accept($0)
		}

		former.append(sectionFormer:
			socialMediaSection, textSection, mediaSection, scheduledSection)
		//			.onCellSelected { _ in }

		output
			.postPages
			.filter { !$0.isEmpty }
			.distinctUntilChanged()
			.drive(onNext: { [weak self] postPage in
				if let `self` = self {
					self.insertSectionWithPages(postPages: postPage,
												in: self.former,
												below: socialMediaSection)
				}
			})
			.disposed(by: disposeBag)
	}

	//Header
	private let createHeader: ((String) -> ViewFormer) = { text in
		return LabelViewFormer<PostingFormHeaderFooterView>(instantiateType: .Nib(nibName: "PostingHeader")) {
			$0.headerView.backgroundColor = BRXNDColors.veryLightBlue
		}
		.configure {
			$0.viewHeight = 60
			$0.text = text
		}
	}

	// pages

	private func insertSectionWithPages(postPages: [PostPage],
										in former: Former,
										below: SectionFormer ) {

		var rowFormers: [RowFormer] = []
		postPages.forEach { page in
			let pageForm = PagesFormableRow<PagesFormTableViewCell>(instantiateType: .Nib(nibName: PagesFormTableViewCell.className)) {
				$0.formTitleLabel()?.text = page.name
			}.configure {

				if postPages.firstIndex(of: page) == 0 {
					$0.cell.cornerRadius = 8
					$0.cell.clipsToBounds = true
					$0.cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
				} else if postPages.endIndex - 1 == postPages.firstIndex(of: page) {

					$0.cell.cornerRadius = 8
					$0.cell.clipsToBounds = true
					$0.cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
				}

				$0.postPage = page
				$0.rowHeight = 60
				$0.cell.configureImage(with: page.picture.url)
			}.onPostPageSelected { [weak self] in
				self?.viewModel.input.selectedPostPage.accept($0)
			}
			rowFormers.append(pageForm)
		}

		let pagesSection = SectionFormer(rowFormers: rowFormers)
			.set(headerViewFormer: createHeader("Select a page"))

		former.insertUpdate(sectionFormer: pagesSection, below: below)
	}

	// schedule

	private lazy var scheduledDatePickerRow: RowFormer = {
		return InlineDatePickerRowFormer<FormInlineDatePickerCell> {
			$0.formTitleLabel()?.text = "Choose time"
			$0.formTitleLabel()?.textColor = .black
		}.inlineCellSetup {
			$0.datePicker.datePickerMode = .dateAndTime
			$0.datePicker.minimumDate = Date(timeIntervalSinceNow: TimeInterval(60 * 60)) // 1 hour
			$0.datePicker.maximumDate = Date(timeIntervalSinceNow: TimeInterval(60 * 60 * 24 * 150)) //5 months
		}.displayTextFromDate(String.mediumDateNoTime)
			.onDateChanged { [weak self] in
				self?.viewModel.input.scheduledDate.accept($0)
		}
//		.configure {
//
//			$0.cell.cornerRadius = 8
//			$0.cell.clipsToBounds = true
//			$0.cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//		}
	}()
	
	private func toggleScheduledRow(shouldToggle: Bool,
									sectionBottom: RowFormer,
									in former: Former,
									with newRow: RowFormer,
									animation: UITableView.RowAnimation = .left) {
		if shouldToggle {
			former.insertUpdate(rowFormer: newRow,
								below: sectionBottom,
								rowAnimation: animation)
		} else {
			former.removeUpdate(rowFormer: newRow, rowAnimation: animation)
		}
	}
}

extension PostingContainerViewController {
	private func animateLoading() {
		DispatchQueue.main.async { [weak self] in
			guard let sSelf = self else { return }
			sSelf.startAnimating(nil, message: "Uploading...",
								 messageFont: nil,
								 type: .circleStrokeSpin,
								 color: nil, padding: nil,
								 displayTimeThreshold: nil,
								 minimumDisplayTime: nil,
								 backgroundColor: nil,
								 textColor: nil,
								 fadeInAnimation: nil)
		}
	}
}
