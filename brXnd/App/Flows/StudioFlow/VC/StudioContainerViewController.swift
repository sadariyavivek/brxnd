//
//  StudioContainerViewController.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-07-26.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

protocol StudioContainerView: BaseView where Self: UIViewController {
	var viewModel: StudioViewModelType! { get set }
	func showSocialMediaAlert()
}

public struct StudioCellConstants {
	static let brandReuseIdentifier: String = "brandCell"
	static let studioReuseIdentifier: String = "studioItemCell"
}

private struct StudioXibConstants {
	static let brandCollectionViewCell: String = "BrandCollectionViewXibCell"
}

private enum BrandChoice: String {
	case delete = "Delete brand"
	case edit = "Edit brand"
	case cancel = "Cancel"
}

final class StudioContainerViewController: UIViewController, StudioContainerView {

	var viewModel: StudioViewModelType!
    let userapi:UserAPI = UserAPI()
	private let disposeBag = DisposeBag()

	@IBOutlet weak var brandView: UIView!
	@IBOutlet weak var studioView: UIView!

	@IBOutlet weak var brandContainerView: UIView!
	@IBOutlet weak var studioItemsContainerView: UIView!

	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var studioLabel: UILabel!

	@IBOutlet weak var draftsButton: UIButton!
    var isTockenNotSubmited = false
    
	override func viewDidLoad() {
		super.viewDidLoad()

		setupComponents()
		setupUI()
		setupCollectionViewContainers()

		let output = viewModel
			.output

		output
			.isRefreshing
			.drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
			.disposed(by: disposeBag)

		output
			.error
			.drive(onNext: { [weak self] error in
				guard let error = error else { return }
				switch error {
				case let error as StudioServiceError where error == .empty || error == .emptyBrands:
					self?.createNewBrandAlert()
				default:
					self?.presentAlertWithTitle(title: "Error", message: "\(error.localizedDescription)", options: "Ok",
												completion: { _ in })
				}
			}).disposed(by: disposeBag)

		output
			.deleteStudioItemResponse
			.drive(onNext: { [weak self] result in
				switch result {
				case .failure(let error):
					self?.presentAlertWithTitle(title: "Error deleting asset", message: "\(error.localizedDescription)", options: "Ok",
												completion: { _ in })
				case .success:
					self?.presentAlertWithTitle(title: "Success!", message: "Studio asset deleted", options: "Ok",
												completion: { _ in})
				}
			}).disposed(by: disposeBag)

		output
			.deleteBrandResponse
			.drive(onNext: { [weak self] result in
				switch result {
				case .failure(let error):
					self?.presentAlertWithTitle(title: "Error deleting brand", message: "\(error.localizedDescription)", options: "Ok",
												completion: { _ in })
				case .success:
					self?.presentAlertWithTitle(title: "Success!", message: "Brand deleted", options: "Ok",
												completion: { _ in})
				}
			}).disposed(by: disposeBag)

		output
			.uploadNewAssetResponse
			.debounce(.seconds(3))
			.drive(onNext: { [weak self] result in
				switch result {
				case .failure(let error):
					self?.presentAlertWithTitle(title: "Error uploading asset", message: "\(error.localizedDescription)", options: "Ok",
												completion: { _ in })
				case .success:
					self?.presentAlertWithTitle(title: "Success!", message: "New asset uploaded", options: "Ok",
												completion: { _ in})
				}
			}).disposed(by: disposeBag)
	}
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if !isTockenNotSubmited {
            
            UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
              [weak self] granted, error in
              guard let self = self else { return }
              print("Permission granted: \(granted)")
              
              guard granted else { return }
            }
                
            userapi.getUserInfo { result in
                result.map { responce in
                    print(responce.id!)
                    print(responce.email!)
                    print("=================")
                    DispatchQueue.main.sync {
                        self.submitDeviceTocekn(userID: responce.id!)
                    }
                }
            }
        }
    }
    
    func submitDeviceTocekn(userID:Int) {
          
          //PostsAPIProvider.retrieveInstaPostsFor.path
        let dicpar: NSMutableDictionary = NSMutableDictionary()
        
        dicpar.setValue("\(userID)", forKey: "user_id")
        dicpar.setValue("ios", forKey: "type")
        dicpar.setValue((UIApplication.shared.delegate as! AppDelegate).deviceTocken, forKey:"device_token")
        
        var dicheader: NSMutableDictionary = NSMutableDictionary()
          //dicheader.setValue("application/json", forKey: "Accept")
         // dicheader.setValue(Current.stagingAuthToken, forKey: "Authorization")
        //dicheader.setValue(user!.webAccessToken!, forKey: <#T##String#>)
                
        for (key,value) in Current.getHeadersWithAccessToken() {
            dicheader.setValue(value, forKey: key)
        }
        
        print(dicheader)
        print(dicpar)
        
          var strUrl: String = "https://brxnd.com.au/api/v1/sent_device_token"
          
          Webservice_VC().call_webservice_post(view_load: self.view, str_URL: strUrl, dict_par: dicpar, dict_header: dicheader) { (data, error) in
              DispatchQueue.main.sync {
                  if error != nil {
                     
                  } else {
                      if data != nil {
                          let dictdata: NSDictionary? = Data_Parser().call_webservice_dict_parse(vc: self, data: data)
                          print(dictdata)
                          if dictdata?.object(forKey: "message") != nil && dictdata?.object(forKey: "message") as! String == "The device token was updated!" {
                            self.isTockenNotSubmited = true
                          }
                          else{
                              
                          }
                      }
                      else{
                          
                      }
                  }
              }
          }
      }

	fileprivate func createNewBrandAlert() {
		self.presentAlertWithTitle(title: "No brands created yet...", message: "Create one?", options: "Yes!",
								   completion: { _ in self.viewModel.input.createNewLogoAction.execute()})
	}

	private func setupUI() {

		setTitles(navigationTitle: "BRXND", tabBarTitle: "Studio")

		navigationItem.rightBarButtonItem?.tintColor = .black
		navigationItem.leftBarButtonItem?.tintColor = .black
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.black,
			NSAttributedString.Key.font: BRXNDFonts.sourceSansProsemiBold13
		]

		view.backgroundColor = BRXNDColors.veryLightBlue
		brandView.backgroundColor = BRXNDColors.veryLightBlue
		studioView.backgroundColor = BRXNDColors.veryLightBlue

		headerLabel.font = BRXNDFonts.openSansRegular13.withSize(22)
		studioLabel.font = BRXNDFonts.openSansRegular13.withSize(36)

		draftsButton.isEnabled = false
		draftsButton.isHidden = true

	}

	private func setupCollectionViewContainers() {

		// MARK: - Brand Collection View

		let brandCollectionView = BrandCollectionView(frame: brandContainerView.frame,
													  collectionViewLayout: UICollectionViewFlowLayout(),
													  viewModel: viewModel)

		let brandFlowLayout = brandCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
		brandFlowLayout.scrollDirection = .horizontal

		brandCollectionView.register(UINib(nibName: StudioXibConstants.brandCollectionViewCell, bundle: nil),
									 forCellWithReuseIdentifier: StudioCellConstants.brandReuseIdentifier)

		brandCollectionView.backgroundColor = BRXNDColors.veryLightBlue
		brandContainerView.addSubview(brandCollectionView)

		brandCollectionView.translatesAutoresizingMaskIntoConstraints = false
		brandCollectionView.topAnchor.constraint(equalTo: brandContainerView.topAnchor).isActive = true
		brandCollectionView.leadingAnchor.constraint(equalTo: brandContainerView.leadingAnchor).isActive = true
		brandCollectionView.trailingAnchor.constraint(equalTo: brandContainerView.trailingAnchor).isActive = true
		brandCollectionView.heightAnchor.constraint(equalTo: brandContainerView.heightAnchor).isActive = true

		brandCollectionView.onBrandDeleteAlert = { [weak self] brandID in
			self?.showBrandActionSheet(choice: {
				switch $0 {
				case .delete:
					self?.viewModel.input.deleteBrand.accept(brandID)
				case .edit:
					#if DEBUG
					print("Show edit flow")
					#endif
				default:
					break
				}
			})
		}

		// MARK: - Studio Item Collection View

		let studioItemCollectionView = StudioItemCollectionView(frame: .zero,
																collectionViewLayout: PinterestStyleLayout(),
																viewModel: viewModel)

		studioItemCollectionView.register(StudioItemCollectionViewCell.self,
										  forCellWithReuseIdentifier: StudioCellConstants.studioReuseIdentifier)
		studioItemCollectionView.backgroundColor = BRXNDColors.veryLightBlue
		studioItemsContainerView.addSubview(studioItemCollectionView)

		studioItemCollectionView.translatesAutoresizingMaskIntoConstraints = false
		studioItemCollectionView.topAnchor.constraint(equalTo: studioItemsContainerView.topAnchor).isActive = true
		studioItemCollectionView.leadingAnchor.constraint(equalTo: studioItemsContainerView.leadingAnchor).isActive = true
		studioItemCollectionView.trailingAnchor.constraint(equalTo: studioItemsContainerView.trailingAnchor).isActive = true
		studioItemCollectionView.heightAnchor.constraint(equalTo: studioItemsContainerView.heightAnchor).isActive = true

		studioItemCollectionView.onItemDeleteAlert = { [weak self] asset in
			self?.showRemoveActionSheet(choice: { shouldDelete in
				if shouldDelete {self?.viewModel.input.deleteStudioItem.accept(asset)}
			})
		}
	}

	private func showRemoveActionSheet(choice: @escaping (Bool) -> Void) {
		let removeAction = UIAlertAction(title: "Remove from library", style: .destructive) { _ in choice(true)}
		let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in choice(false)}
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(removeAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true, completion: nil)
	}

	private func showBrandActionSheet(choice: @escaping (BrandChoice) -> Void ) {
		let removeAction = UIAlertAction(title: BrandChoice.delete.rawValue, style: .destructive) { _ in choice(.delete)}
		//				let editAction = UIAlertAction(title: BrandChoice.edit.rawValue, style: .default) { _ in choice(.edit)}
		let cancelAction = UIAlertAction(title: BrandChoice.cancel.rawValue, style: .default) { _ in choice(.cancel)}
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(removeAction)
		//		alert.addAction(editAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true, completion: nil)
	}

	private func setupComponents() {
		let rightImage = UIImage(named: "addImage")?.withRenderingMode(.alwaysTemplate)
		let rightBarButtonItem = UIBarButtonItem(image: rightImage,
												 style: .plain,
												 target: self,
												 action: nil)

		rightBarButtonItem
			.rx
			.tap
			.subscribe(onNext: { [weak self] in
				self?.showLibraryPicker()
			}).disposed(by: disposeBag)

		navigationItem.rightBarButtonItem = rightBarButtonItem

		let leftImage = UIImage(named: "cameraIcon")?.withRenderingMode(.alwaysTemplate)
		var leftBarButtonItem = UIBarButtonItem(image: leftImage,
												style: .plain,
												target: self,
												action: nil)

		leftBarButtonItem
			.rx
			.action = viewModel.input.cameraClickedAction

		navigationItem.leftBarButtonItem = leftBarButtonItem

		let output = viewModel
			.output
			.brandMutationButtonsEnabled

		output
			.drive(rightBarButtonItem.rx.isEnabled)
			.disposed(by: disposeBag)

		output
			.drive(leftBarButtonItem.rx.isEnabled)
			.disposed(by: disposeBag)
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

	public func showSocialMediaAlert() {
		self.presentAlertWithTitle(title: "Social Media",
								   message: "Please log-in social media first",
								   options: "Ok",
								   completion: { _ in })
	}
}

extension StudioContainerViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	/*coordinators would be not reasonable to use here*/

	private func showLibraryPicker() {
		if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			imagePicker.allowsEditing = true
			//			imagePicker.mediaTypes = ["public.image", "public.movie"]
			imagePicker.mediaTypes = ["public.image"]
			imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			self.errorMessage(with: "Photo Library")
		}
	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

		if let pickedPhoto = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
			let imageData = pickedPhoto.pngData() {
			viewModel.input.newStudioAssetUpload.accept(imageData)
		} else {
			#if DEBUG
			print("Failed to generate the image")
			#endif
		}
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
