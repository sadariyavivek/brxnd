//
//  NewBrandViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-08-08.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import Device
import NVActivityIndicatorView
import Nuke
import FlexColorPicker

protocol NewBrandView: BaseView {
	var viewModel: NewBrandViewModelType! { get set }
}

final class NewBrandViewController: UIViewController, NewBrandView, BindableType, NVActivityIndicatorViewable {

    var colorPickerController = DefaultColorPickerViewController()
    var pickedColor = #colorLiteral(red: 0.6813090444, green: 0.253660053, blue: 1, alpha: 1)
    
    @IBOutlet weak var btnSlcAllBrand: UIButton!
    @IBOutlet weak var tblFBPagesList: UITableView!
    
    @IBOutlet weak var mainContainerView: UIView!
	@IBOutlet weak var uploadLogoContainerView: UIView!
	@IBOutlet weak var fieldsContainerView: UIView!
    @IBOutlet weak var viewSlcFBPages: UIView!
    
	@IBOutlet weak var createNewBrandLabel: UILabel!
	@IBOutlet weak var uploadYourBrandLogoLabel: UILabel!
	@IBOutlet weak var brandDetailsLabel: UILabel!

	@IBOutlet weak var logoTutorialTextView: UITextView!

    @IBOutlet weak var brandColorTextFild: UITextField!
    @IBOutlet weak var brandNameTextField: UITextField!
	@IBOutlet weak var brandDescriptionTextField: UITextField!

	@IBOutlet weak var uploadLogoButton: UIButton!
	@IBOutlet weak var saveBrandButton: UIButton!
	@IBOutlet weak var saveAsDraftButton: UIButton!
	//@IBOutlet weak var pickBrandColorButton: UIButton!
    @IBOutlet weak var btnSlcFBPage: UIButton!
    
	@IBOutlet weak var brandFieldsStackView: UIStackView!

	var viewModel: NewBrandViewModelType!

    var listFBpages = [FBPage]()
	// MARK: - Private
	private let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupComponents()
		setupUI()
		bindViewModel()
        getFBpages()
        
        colorPickerController.delegate = self
	}
    
    @IBAction func actSlcAllFBPages(_ sender: Any) {
        if btnSlcAllBrand.title(for: .normal) == "Deselect All"{
            let totalRows = tblFBPagesList.numberOfRows(inSection: 0)
            for row in 0..<totalRows {
                tblFBPagesList.deselectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false)
            }
            btnSlcAllBrand.setTitle("Select All", for: .normal)
        }
        else {
            let totalRows = tblFBPagesList.numberOfRows(inSection: 0)
            for row in 0..<totalRows {
                tblFBPagesList.selectRow(at: NSIndexPath(row: row, section: 0) as IndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            }
            btnSlcAllBrand.setTitle("Deselect All", for: .normal)
        }
        
        
    }
    
    @IBAction func actSelectFBPage(_ sender: Any) {
        let arr = tblFBPagesList.indexPathsForSelectedRows ?? []
        for indexpath in arr{
            let page = listFBpages[indexpath.row]
        }
        
        btnSlcFBPage.setTitle("\(arr.count) Selected Pages", for: .normal)
        viewSlcFBPages.isHidden = true
    }
    
    
    func getFBpages() {
        
        print("Test")
        BrandAPI().getFBPages { (result) in
            switch result {
                  case .success(let pages):
                    
                    //let test = newJSONDecoder().decode([FBPage].self, from: pages)
                    
                    
                    DispatchQueue.main.sync {
                        print("-------------------")
                        print("-------------------\(pages)")
                        self.listFBpages = pages
                        self.tblFBPagesList.reloadData()
                    }
                    return
                  case .failure(let error):
                    print(error)
                    return
            }
        }
    }
    
    @IBAction func actSlcColor(_ sender: Any) {
        self.view.endEditing(true)
        navigationController?.pushViewController(colorPickerController, animated: true)
    }
    
    
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.stopAnimating()
	}

	func bindViewModel() {

		let input = viewModel
			.input

		brandNameTextField
			.rx
			.text
			.orEmpty
			.bind(to: viewModel.input.brandName)
			.disposed(by: disposeBag)
        
        brandColorTextFild
        .rx
        .text
        .orEmpty
        .bind(to: viewModel.input.brandColor)
        .disposed(by: disposeBag)

//        viewModel
//            .input
//            .brandColor
//            .bind(to: (pickBrandColorButton.titleLabel?.rx.text)!)
//            .disposed(by: disposeBag)
        
        //pickBrandColorButton.title(for: .normal)
//        self.viewModel.shiftNameText
//        .asObservable()
//        .map { text -> String? in
//            return Optional(text)
//        }
//        .bind(to:self.shiftLabel.rx.text)
//        .disposed(by:self.disposeBag)
            
//        viewModel.shiftNameText
//        .asObservable()
//        .map { $0 }
//        .bind(to:self.shiftLabel.rx.text)
//        .disposed(by:self.disposeBag)
        
		brandDescriptionTextField
			.rx
			.text
			.orEmpty
			.bind(to: viewModel.input.brandDescription)
			.disposed(by: disposeBag)
        
        saveBrandButton
			.rx
			.tap
			.asDriver()
			.drive(onNext: { _ in
				input.saveTap.accept(.defaultBrand)
			})
			.disposed(by: disposeBag)

		saveAsDraftButton
			.rx
			.tap
			.asDriver()
			.drive(onNext: { _ in
				input.saveTap.accept(.asDraft)
			})
			.disposed(by: disposeBag)

		let output = viewModel
			.output

		output
			.logoImageDriver
			.filter { $0 != nil }
			.drive(onNext: { [weak self] item in
				guard let self = self else { return }
				self.uploadLogoButton.subviews.forEach {$0.removeFromSuperview()}
				let imgView = UIImageView(frame: self.uploadLogoButton.bounds)
				imgView.image = item
				imgView.contentMode = .scaleAspectFill
				imgView.clipsToBounds = true
				self.uploadLogoButton.addSubview(imgView)
			}).disposed(by: disposeBag)

		output
			.isSaveEnabled
			.drive(saveBrandButton.rx.isEnabled)
			.disposed(by: disposeBag)

		output
			.isSaveEnabled
			.drive(saveAsDraftButton.rx.isEnabled)
			.disposed(by: disposeBag)

		output
			.isLoading
			.drive(onNext: { [weak self] isLoading in
				isLoading ?
					self?.animateLoading() : self?.stopAnimating()
			}).disposed(by: disposeBag)

		output
			.saveResult
			.drive(onNext: { [weak self] result in
				switch result {
				case .failure(let err):
					self?.presentAlertWithTitle(title: "Error",
												message: "\(err.localizedDescription)", options: "Ok", completion: { _ in })
				case .success: break
				}
			}).disposed(by: disposeBag)
	}

	private func setupUI() {

		let color = BRXNDColors.veryLightBlue

		view.backgroundColor = color
		mainContainerView.backgroundColor = color
		uploadLogoContainerView.backgroundColor = color
//		fieldsContainerView.backgroundColor = color

		logoTutorialTextView.backgroundColor = color

		navigationController?.navigationBar.backgroundColor = color
		
		title = "BRXND"

		navigationItem.rightBarButtonItem?.tintColor = .black
		navigationItem.leftBarButtonItem?.tintColor = .black
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.black,
			NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 10.2)!
		]

		brandColorTextFild.isEnabled  = true
		//pickBrandColorButton.setTitle("Select Brand color", for: .normal)
        brandColorTextFild.layer.cornerRadius = brandColorTextFild.bounds.height / 2
        btnSlcFBPage.layer.cornerRadius = btnSlcFBPage.bounds.height / 2
        
		brandNameTextField.borderStyle = .none
		brandNameTextField.layer.cornerRadius = brandNameTextField.bounds.height / 2
		brandNameTextField.layer.borderWidth = 1.0
		brandNameTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
		brandNameTextField.layer.masksToBounds = false
		brandNameTextField.layer.backgroundColor = UIColor.white.cgColor
		brandNameTextField.addPadding()

		brandDescriptionTextField.borderStyle = .none
		brandDescriptionTextField.layer.cornerRadius = brandNameTextField.bounds.height / 2
		brandDescriptionTextField.layer.borderWidth = 1.0
		brandDescriptionTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
		brandDescriptionTextField.layer.masksToBounds = false
		brandDescriptionTextField.layer.backgroundColor = UIColor.white.cgColor
		brandDescriptionTextField.addPadding()

		saveBrandButton.tintColor = UIColor.white
		saveBrandButton.backgroundColor = BRXNDColors.camel
		saveBrandButton.cornerRadius = 16
		saveBrandButton.titleLabel?.font = BRXNDFonts.sourceSansProsemiBold17.withSize(15)

		saveAsDraftButton.tintColor = UIColor.gray
		saveAsDraftButton.cornerRadius = 16
		saveAsDraftButton.titleLabel?.font = BRXNDFonts.sourceSansProsemiBold17.withSize(15)

		var spacer: UIView {
			let view = UIView()
			view.backgroundColor = color
			return view.copy() as! UIView
		}
		switch Device.size() {
		case .screen4Inch, .screen4_7Inch: brandFieldsStackView.addArrangedSubview(spacer)
		default: for _ in 0...2 { brandFieldsStackView.addArrangedSubview(spacer)}
		}
	}

	private func setupComponents() {
		let rightBarButtonItem = UIBarButtonItem(title: "Cancel",
												 style: .plain,
												 target: self,
												 action: nil)
		var attributes = [NSAttributedString.Key: AnyObject]()
		attributes[.foregroundColor] = UIColor.red
		rightBarButtonItem.setTitleTextAttributes(attributes,
												  for: [.normal])
		navigationItem.rightBarButtonItem = rightBarButtonItem

		rightBarButtonItem
			.rx
			.tap
			.take(1)
			.subscribe(onNext: { [weak self] in
				self?.viewModel.input.dismissAction.execute(false)
			}).disposed(by: disposeBag)

		uploadLogoButton
			.rx
			.tap
			.subscribe(onNext: { [weak self] in
				self?.showLibraryPicker()
			}).disposed(by: disposeBag)
	}
	private func animateLoading() {
		DispatchQueue.main.async { [weak self] in
			guard let sSelf = self else { return }
			sSelf.startAnimating(nil, message: "Loading...",
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
    
    @IBAction func actSlcFBPage(_ sender: Any) {
        viewSlcFBPages.isHidden = false
    }
    
}

extension NewBrandViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	private func showLibraryPicker() {
		if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.allowsEditing = true
			imagePicker.mediaTypes = ["public.image"]
			imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			self.errorMessage(with: "Photo Library")
		}
	}
	private func errorMessage(with text: String) {
		alert(type: .close,
			  title: "No access to \(text)",
			text: "You can grant access to brXnd from the Settings app")
			.asObservable()
			.take(.seconds(3), scheduler: MainScheduler.instance)
			.subscribe()
			.disposed(by: disposeBag)
	}
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let pickedPhoto 	= info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			viewModel.input.logoImage.accept(pickedPhoto)
		}
		picker.dismiss(animated: true, completion: nil)
	}
}


extension NewBrandViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listFBpages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblFBPagesList.dequeueReusableCell(withIdentifier: "cell_brands", for: indexPath) as? UITableViewCell
        var lbl = cell?.contentView.viewWithTag(1)
         as? UILabel
        print(listFBpages[indexPath.row].name)
        lbl!.text = listFBpages[indexPath.row].name
        
        if let fullURL = URL(string:(listFBpages[indexPath.row].picture?.url ?? "")) {
          let options = ImageLoadingOptions(
                               placeholder: UIImage(named: "emptyStudio"),
                                failureImage: UIImage(named: "emptyStudio"),
                contentModes: .init(success: .scaleAspectFill, failure: .scaleAspectFit, placeholder: .scaleAspectFit)
            )
          let req = ImageRequest(url: fullURL)
            Nuke.loadImage(with: req, options: options, into: (cell!.contentView.viewWithTag(2) as! UIImageView))
        }
//        print(brandsList![indexPath.row].logoPath)
//        (cell.contentView.viewWithTag(1) as! UILabel).text = brandsList![indexPath.row].name
//        if let fullURL = URL(string:BRXNDBaseURL.url.absoluteString + brandsList![indexPath.row].logoPath!) {
//          let options = ImageLoadingOptions(
//                               placeholder: UIImage(named: "emptyStudio"),
//                                failureImage: UIImage(named: "emptyStudio"),
//                contentModes: .init(success: .scaleAspectFill, failure: .scaleAspectFit, placeholder: .scaleAspectFit)
//            )
//          let req = ImageRequest(url: fullURL)
//            Nuke.loadImage(with: req, options: options, into: (cell.contentView.viewWithTag(2) as! UIImageView))
//        }
        return cell!
    }
      
      
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}


extension NewBrandViewController: ColorPickerDelegate {

    func colorPicker(_: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        pickedColor = selectedColor
        brandColorTextFild.backgroundColor = selectedColor
        brandColorTextFild.text = selectedColor.hexString
        brandColorTextFild.textColor = selectedColor.inverse()
    }

    func colorPicker(_: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
        
        navigationController?.popViewController(animated: true)
    }
}
