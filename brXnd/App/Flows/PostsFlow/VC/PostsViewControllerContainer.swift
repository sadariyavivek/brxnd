//
//  PostsViewControllerContainer.swift
//  brXnd
//
//  Created by Andrian Sergheev on 2019-06-28.
//  Copyright © 2019 Andrian Sergheev. All rights reserved.
//

import EmptyStateKit


public struct PostsCellConstants {
	static let pagesReuseIdentifier: String = "pageCell"
	static let postsReuseIdentifier: String = "postsCell"
}

private struct PostsXibConstants {
	static let postsCollectionViewCell: String = "PostsCollectionViewXibCell"
}



final class PostsViewControllerContainer: UIViewController, PostsView,UITableViewDelegate,UITableViewDataSource {

	var viewModel: PostsViewModelType!
     
	private let disposeBag = DisposeBag()

	@IBOutlet weak var pagesContainerView: UIView!
	@IBOutlet weak var postsContainerView: UIView!
    @IBOutlet weak var instapostlist: UITableView!
    @IBOutlet weak var viewinstapost: UIView!
    @IBOutlet weak var tblview: UITableView!
    
    var arrInstaPost:NSMutableArray = NSMutableArray()
    var strNextPostUrl:String = String()
    var isPagingEnable:Bool = false
    
	override func viewDidLoad() {
		super.viewDidLoad()

		//force calculating the frames before adding the collectionViews
		self.view.layoutIfNeeded()

 //       let studioService = StudioService()
//        let brands = studioService
//            .fetchBrands()
//            .map { result -> BrandResponse in
//                switch result {
//                case .success(let value):
//                    print(value.brands?.data)
//                    return value
//                case .failure(let error):
//                    print("Error")
//                    throw error
//                }
//        }
        
		setupComponents()
		setupUI()

		let this = self

		let input = viewModel
			.input

		this
			.rx
			.methodInvoked(#selector(viewDidAppear(_:)))
			.map { _ in }
			.bind(to: input.viewDidAppearTrigger)
			.disposed(by: disposeBag)

		let output = viewModel
			.output
		
		output
			.isRefreshing
			.drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
			.disposed(by: disposeBag)

		output
			.error
			.drive(onNext: { [weak self] error in
				if let error = error {
					if case PostsServiceError.notLoggedInSocialMedia = error {
						self?.view.emptyState.format = BRXNDEmptyState.socialMediaFormat()
						self?.view.emptyState.show(BRXNDEmptyState.notLoggedInSocialMedia)
					} else {
//						self?.presentAlertWithTitle(title: "Error",
//													message: "\(error.localizedDescription)", options: "Ok", completion: { _ in })
					}
				} else {
					self?.view.emptyState.hide()
				}
			}).disposed(by: disposeBag)

		self.view.emptyState.delegate = self
        //getInstaPost()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        getInstaPost(isNextPost: false)
    }
    
    func getInstaPost(isNextPost:Bool) {
        
        if !isNextPost{
            arrInstaPost.removeAllObjects()
        }
        
        tblview.reloadData()
        //PostsAPIProvider.retrieveInstaPostsFor.path
        let dicpar: NSMutableDictionary = NSMutableDictionary()
        let dicheader: NSMutableDictionary = NSMutableDictionary()
        //dicheader.setValue("application/json", forKey: "Accept")
        //dicheader.setValue(Current.stagingAuthToken, forKey: "Authorization")
        for (key,value) in Current.getHeadersWithAccessToken() {
            dicheader.setValue(value, forKey: key)
        }
        
        
        var strUrl: String = String()
        if isNextPost {
            strUrl = strNextPostUrl
        }else {
            strUrl = "https://brxnd.com.au/api/v1/instagram-posts"
        }
        
        Webservice_VC().call_webservice_get(view_load: self.view, str_URL: strUrl, dict_par: dicpar, dict_header: dicheader) { (data, error) in
            DispatchQueue.main.sync {
                if error != nil {
                    Alert_view().error_Alert("Error", message: "There is some issue with your connection make sure you have active internet connection.", vc: self)
                } else {
                    if data != nil {
                        let dictdata: NSDictionary? = Data_Parser().call_webservice_dict_parse(vc: self, data: data)
                        print(dictdata)
                        if dictdata?.object(forKey: "data") != nil {
                            let arr: NSArray = dictdata?.object(forKey: "data") as! NSArray
                            
                            if !isNextPost{
                                self.arrInstaPost = arr.mutableCopy() as! NSMutableArray
                            }
                            else{
                                for data in arr.mutableCopy() as! NSMutableArray{
                                    self.arrInstaPost.add(data as! Dictionary<String,Any>)
                                }
                            }
                            
                            if let strNextUrl:String = dictdata?.object(forKey: "next_page_url") as? String{
                                self.isPagingEnable = true
                                self.strNextPostUrl = strNextUrl
                            }
                            else{
                                self.isPagingEnable = false
                            }
                            
                            if self.arrInstaPost.count == .zero {
                                self.tblview.isHidden = true
                                Alert_view().error_Alert("Error", message: "No scheduled Instapost will be found.", vc: self)
                            } else {
                                self.tblview.isHidden = false
                                self.tblview.reloadData()
                            }
                        }
                        else{
                            Alert_view().error_Alert("Error", message: dictdata?.object(forKey: "message") as! String,vc: self)
                        }
                    }
                    else{
                        Alert_view().error_Alert("Error", message: "Can't able to get data. Please try again.", vc: self)
                    }
                }
            }
        }
    }

	private func setupComponents() {

		// MARK: - Facebook Pages
		let pagesCollectionView = PagesCollectionView(frame: .zero,
													  collectionViewLayout: PagesCollectionView.layout(superViewFrame: .zero),
													  viewModel: viewModel)

		pagesCollectionView.register(PagesCollectionViewCell.self,
									 forCellWithReuseIdentifier: PostsCellConstants.pagesReuseIdentifier)

		pagesCollectionView.backgroundColor = BRXNDColors.veryLightBlue

		pagesContainerView.addSubview(pagesCollectionView)

		pagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
		pagesCollectionView.topAnchor.constraint(equalTo: pagesContainerView.topAnchor).isActive = true
		pagesCollectionView.leadingAnchor.constraint(equalTo: pagesContainerView.leadingAnchor).isActive = true
		pagesCollectionView.trailingAnchor.constraint(equalTo: pagesContainerView.trailingAnchor).isActive = true
		pagesCollectionView.heightAnchor.constraint(equalTo: pagesContainerView.heightAnchor).isActive = true

		pagesCollectionView.cornerRadius = 8

		// MARK: - Facebook Posts

		let postsCollectionView = PostsCollectionView(frame: .zero,
													  collectionViewLayout: PostsCollectionView.layout(superViewFrame: postsContainerView.frame),
													  viewModel: viewModel)

		postsCollectionView.register(UINib(nibName: PostsXibConstants.postsCollectionViewCell, bundle: nil),
									 forCellWithReuseIdentifier: PostsCellConstants.postsReuseIdentifier)

		postsCollectionView.backgroundColor = BRXNDColors.veryLightBlue

		postsContainerView.addSubview(postsCollectionView)

		postsCollectionView.translatesAutoresizingMaskIntoConstraints = false
		postsCollectionView.topAnchor.constraint(equalTo: postsContainerView.topAnchor).isActive = true
		postsCollectionView.leadingAnchor.constraint(equalTo: postsContainerView.leadingAnchor).isActive = true
		postsCollectionView.trailingAnchor.constraint(equalTo: postsContainerView.trailingAnchor).isActive = true
		postsCollectionView.heightAnchor.constraint(equalTo: postsContainerView.heightAnchor).isActive = true

		postsCollectionView.cornerRadius = 8
	}

	private func setupUI() {
		view.backgroundColor = BRXNDColors.veryLightBlue
		postsContainerView.backgroundColor = BRXNDColors.veryLightBlue

		pagesContainerView.cornerRadius = 8
		postsContainerView.cornerRadius = 8
        
    
        setTitles(navigationTitle: "BRXND", tabBarTitle: "Studio")

        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: BRXNDFonts.sourceSansProsemiBold13
        ]

        view.backgroundColor = BRXNDColors.veryLightBlue
        

	}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInstaPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:Cellinstapost = tblview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cellinstapost
       
        let dictpost:Dictionary<String,Any> = arrInstaPost.object(at: indexPath.row) as! Dictionary<String,Any>
        
        //print(dictpost)
        let dictusr:Dictionary<String,Any> = dictpost["user"] as! Dictionary<String,Any>
        
        if let imgpath = dictusr["avatar"] as? String{
            cell.setUsrimg(strPath: imgpath)
        }
        else{
            cell.imgusr.image = UIImage(named: "defaultUser")
        }
        
        cell.lbluser.text = dictusr["name"] as! String
        cell.lbldate.text = dictpost["scheduled_publish_date"] as! String
        cell.arrimg = dictpost["media"] as! Array
        cell.lblposttitle.text = dictpost["story"] as! String
        cell.collimgslider.reloadData()
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        
        let reloaddistance:CGFloat = 10.0
        
        if y > (h + reloaddistance) {
            if isPagingEnable{
                isPagingEnable = false
                getInstaPost(isNextPost: true)
            }
        }
    }
    
    @IBAction func actAddInstaStory(_ sender: Any) {
        self.performSegue(withIdentifier: "id_addInstaStory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "id_addInstaStory"{
              let vc:AddInstaPostVC = segue.destination as! AddInstaPostVC
              vc.vc = self
          }
    }
    
}
extension PostsViewControllerContainer: EmptyStateDelegate {
	func emptyState(emptyState: EmptyState, didPressButton button: UIButton) {
		let input = viewModel.input
		input.logInSocialMediaAction.execute()
	}
}
