

import UIKit
import RxFeedback
import Nuke
import Device

// swiftlint:disable all
private typealias studioTuple = ([BrandAsset], BrandResponse)
private typealias isPaginated = Bool
private typealias assetsTuple = ([BrandAsset], isPaginated)
// swiftlint:enable all
private struct StudioState {

    var isRefreshing: Bool
    var isLoadingNext: Bool
    var shouldLoadFirstBrand: trigger

    var currentBrandID: BrandID?
    var currentSelectedBrand: BrandData?
    var brands: [BrandData]

    var brandAssets: [BrandAsset]
    var lastAssetID: Int?

    var error: Error?
   
    
    init(brandID: BrandID? = nil) {

        self.isRefreshing = true
        self.isLoadingNext = true
        self.shouldLoadFirstBrand = 0

        self.currentBrandID = brandID
        self.currentSelectedBrand = nil
        self.brands = []

        self.brandAssets = []
        self.lastAssetID = nil

        self.error = nil
    }
}

private extension StudioState {
    static func reduce(state: StudioState, command: StudioEvent) -> StudioState {
        var result = state
        switch command {
        // user actions
        case .refresh:

            if result.currentBrandID == nil ||
                result.currentSelectedBrand == nil {
                ///used to trigger the firstBrandFeedbackLoop, as just setting it to "true" does not trigger a loop
                result.shouldLoadFirstBrand += 1
            } else {
                result.isRefreshing = true

            }
            result.isLoadingNext = false
            result.error = nil
            result.lastAssetID = nil
            return result
        case .reachedBottom:
            result.isLoadingNext = true
            return result
        case .selectNewBrand(let newBrand):
            result.currentBrandID = newBrand.0
            result.currentSelectedBrand = newBrand.1
            result.isLoadingNext = false
            result.isRefreshing = true
            result.lastAssetID = nil
            result.error = nil
            return result

        // machine feedback
        case .initial(let response):
            result.currentBrandID = response.brands?.data?.first?.id
            result.currentSelectedBrand = response.brands?.data?.first
            result.brands = response.brands?.data ?? []
            result.error = nil
            result.isRefreshing = true
            result.isLoadingNext = false
            return result
        case .studioAssetsResponse(let response):
            if response.1 {
                result.brandAssets += response.0
            } else {
                result.brandAssets = response.0
            }
            result.isRefreshing = false
            result.isLoadingNext = false
            result.error = nil
            result.lastAssetID = response.0.last?.id
            return result
        case .studioResponse(let tuple):
            result.isRefreshing = false
            result.error = nil
            result.brandAssets = tuple.0
            result.brands = tuple.1.brands?.data ?? []
            result.lastAssetID = tuple.0.last?.id
            result.isLoadingNext = false
            return result
        case .error(let error):
            #if DEBUG
            print("\(self) received error: \(error) 🌈")
            #endif

            result.error = nil
            result.error = error

            result.brands = []
            result.brandAssets = []

            result.isRefreshing = false
            result.isLoadingNext = false
            result.lastAssetID = nil

            return result
        }
    }
}


private enum StudioEvent {

    //user actions
    case refresh
    case reachedBottom
    case selectNewBrand(BrandID?, BrandData?)

    //reactions
    case initial(BrandResponse)
    case studioResponse(studioTuple)
    case studioAssetsResponse(assetsTuple)
    case error(Error)
}

private extension StudioState {

    static func defaultState(_ brandID: BrandID?) -> StudioState {
        return StudioState(brandID: brandID)
    }

    var shouldRefreshStudio: BrandID? {
        return self.isRefreshing ? self.currentBrandID : nil
    }
  
}
class AddInstaPostVC:UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var lbldt: UILabel!
    @IBOutlet weak var viewDtPkr: UIView!
    @IBOutlet weak var tblview: UITableView!
    @IBOutlet weak var tblBrands: UITableView!
    @IBOutlet weak var btnSlcBrands: UIButton!
    @IBOutlet weak var viewSearch: UIView!
    var vc:PostsViewControllerContainer?
    
    
    var arrimg:Array = Array<Any>()
    var cellWidth:CGFloat = 100
    var isScheduled:Bool = false
    var isEditScheduled:Bool = false
    var scheduledDt:Date = Date()
    let dateFormatter = DateFormatter()
    @IBOutlet weak var viewAttachMedia: UIView!
    @IBOutlet weak var collimgslider: UICollectionView!
    var arrSelectedIndex = [IndexPath]()
    
    let studioService = StudioService()
    var brandsList:[BrandData]?
    var brandsAssets:[BrandAsset]?
    let activityIndicator = RxActivityIndicator()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        //dateFormatter.timeZone = TimeZone(identifier: "UTC")
        lbldt.text = dateFormatter.string(from: scheduledDt)
        viewAttachMedia.isHidden = true
        
        btnSlcBrands.borderWidth = 0.4
        btnSlcBrands.borderColor = UIColor.black
        
        viewSearch.borderWidth = 0.4
        viewSearch.borderColor = UIColor.black
        
        var spacing = 10.0
        cellWidth = (collimgslider.frame.width/2.0)-CGFloat(spacing*2.0)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth*1.5)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = CGFloat(spacing)
        layout.scrollDirection = .vertical
        collimgslider!.collectionViewLayout = layout
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tblview == tableView {
            return UITableView.automaticDimension
        }
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tblview == tableView {
            return 1
        }
        return brandsList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tblview == tableView{
            let cell = tblview.dequeueReusableCell(withIdentifier: "cell_add_post", for: indexPath) as! CellAddInsta
            cell.btnAttachMedia.setTitle("Attach media(\(arrSelectedIndex.count))", for: .normal)
            if isScheduled{
                cell.imgckbox.image = UIImage(named: "ch_ck")
                cell.cnstlblscheduleddt.constant = 30
                cell.lblscheduleddt.isHidden = false
                cell.btnEditSchedulePost.isHidden = false
                cell.lblscheduleddt.text = dateFormatter.string(from: scheduledDt)
            }
            else{
                cell.imgckbox.image = UIImage(named: "ch_not_ck")
                cell.cnstlblscheduleddt.constant = 10
                cell.lblscheduleddt.isHidden = true
                cell.btnEditSchedulePost.isHidden = true
            }
            return cell
        } else {
            let cell = tblBrands.dequeueReusableCell(withIdentifier: "cell_brands", for: indexPath) as! UITableViewCell
            var lbl = cell.contentView.viewWithTag(1)
             as! UILabel
            
            print(brandsList![indexPath.row].logoPath)
            (cell.contentView.viewWithTag(1) as! UILabel).text = brandsList![indexPath.row].name
            if let fullURL = URL(string:BRXNDBaseURL.url.absoluteString + brandsList![indexPath.row].logoPath!) {
              let options = ImageLoadingOptions(
                                   placeholder: UIImage(named: "emptyStudio"),
                                    failureImage: UIImage(named: "emptyStudio"),
                    contentModes: .init(success: .scaleAspectFill, failure: .scaleAspectFit, placeholder: .scaleAspectFit)
                )
              let req = ImageRequest(url: fullURL)
                Nuke.loadImage(with: req, options: options, into: (cell.contentView.viewWithTag(2) as! UIImageView))
            }
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblBrands.isHidden = true
        btnSlcBrands.setTitle(brandsList![indexPath.row].name, for: .normal)
        print(brandsList![indexPath.row].id)
        getAssets(id: String("\(brandsList![indexPath.row].id!)"))
    }
    
    @IBAction func actdissmiss(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
 
    @IBAction func actPostStory(_ sender: Any) {
        let cell = tblview.cellForRow(at: IndexPath(row: 0, section: 0)) as! CellAddInsta
        if cell.tvdescription.text != ""{
            if isScheduled{
                if !arrSelectedIndex.isEmpty{
                   self.addInstaPost(strStory: cell.tvdescription.text!)
                }
                else{
                    Alert_view().error_Alert("Error", message: "Please select atachment.",vc: self)
                }
            }
            else{
                Alert_view().error_Alert("Error", message: "Please select scheduled date.",vc: self)
            }
        }
        else{
            Alert_view().error_Alert("Error", message: "Please enter story decription.",vc: self)
        }
        
    }
    
    @IBAction func actscheduled(_ sender: Any) {
        if isScheduled{
            isScheduled = false
            tblview.reloadData()
        }
        else{
            isScheduled = true
            tblview.reloadData()
            viewDtPkr.isHidden = false
            isEditScheduled = false
        }
    }
    @IBAction func actcancelpicker(_ sender: Any) {
        viewDtPkr.isHidden = true
        if !isEditScheduled{
            isScheduled = false
            tblview.reloadData()
        }
    }
    
    @IBAction func actSlcBrands(_ sender: Any) {
        getBrands(isEdit: false)
    }
    @IBAction func actslcdate(_ sender: Any) {
        viewDtPkr.isHidden = true
        tblview.reloadData()
    }
    
    @IBAction func acteditscheduledpost(_ sender: Any) {
        isEditScheduled = true
        viewDtPkr.isHidden = false
    }
    @IBAction func actpicker(_ sender: Any) {
        scheduledDt = picker.date
        lbldt.text = dateFormatter.string(from: scheduledDt)
    }
    
    @IBAction func actAttachMedia(_ sender: Any) {
        //viewAttachMedia.isHidden = false
        getBrands(isEdit: true)
    }
    
    @IBAction func actCancelSlcImg(_ sender: Any) {
        viewAttachMedia.isHidden = true
    }
    @IBAction func actSlcAttachment(_ sender: Any) {
        if arrSelectedIndex.isEmpty{
            Alert_view().error_Alert("Error", message: "Please select atachment.",vc: self)
        }
        else{
            for index in arrSelectedIndex{
                print(brandsAssets![index.row].url)
            }
            viewAttachMedia.isHidden = true
            tblview.reloadData()
        }
    }
    
    func addInstaPost(strStory:String) {
        //PostsAPIProvider.retrieveInstaPostsFor.path
        let dicpar:NSMutableDictionary = NSMutableDictionary()
        let dicheader:NSMutableDictionary = NSMutableDictionary()
        //dicheader.setValue("application/json", forKey: "Content-Type")
        //dicheader.setValue("application/json", forKey: "Accept")
        //dicheader.setValue(Current.stagingAuthToken, forKey: "Authorization")
        for (key,value) in Current.getHeadersWithAccessToken() {
            dicheader.setValue(value, forKey: key)
        }
        
        dicpar.setValue(strStory, forKey: "story")
        //scheduledDt
        var arrmedia:Array<Any> = Array<Any>()
        for index in arrSelectedIndex{
            print(brandsAssets![index.row])
            print(brandsAssets![index.row].url)
            print(brandsAssets![index.row].type)
            let dic = ["type":brandsAssets![index.row].type!,"url":BRXNDBaseURL.url.absoluteString + brandsAssets![index.row].url!]
            arrmedia.append(dic)
        }
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let updatedAt = dateFormatter.string(from: scheduledDt)
        
        dicpar.setValue(arrmedia, forKey: "media")
        dicpar.setValue(updatedAt, forKey: "scheduled_publish_date")
        
        print(dicpar)
        
        
        Webservice_VC().call_webservice_post_json(view_load: self.view, str_URL: "https://brxnd.com.au/api/v1/instagram-posts", dict_par: dicpar,dict_header: dicheader) { (data, error) in
            DispatchQueue.main.sync {
                if error != nil{
                    Alert_view().error_Alert("Error", message: "There is some issue with your connection make sure you have active internet connection.",vc: self)
                }
                else{
                    if data != nil{
                        let dictdata:NSDictionary? = Data_Parser().call_webservice_dict_parse(vc: self, data: data)
                        print(dictdata)
                        if dictdata?.object(forKey: "dialogType") != nil{
                            if dictdata?.object(forKey: "dialogType") as! String == "success"{
                                    //Alert_view().error_Alert("msgTitle", message: dictdata?.object(forKey: "msgBody") as! String,vc: self)
                                    let alertController = UIAlertController(title: dictdata?.object(forKey: "msgTitle") as! String, message: dictdata?.object(forKey: "msgBody") as! String, preferredStyle: .alert)

                                    // Create the actions
                                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                                        UIAlertAction in
                                        self.dismiss(animated: true) {
                                            self.vc?.getInstaPost(isNextPost: false)
                                        }
                                    }
                                    alertController.addAction(okAction)
                                    self.present(alertController, animated: true, completion: nil)
                            }
                            else{
                                Alert_view().error_Alert("msgTitle", message: dictdata?.object(forKey: "msgBody") as! String,vc: self)
                            }
                            
                        }
                        else{
                            Alert_view().error_Alert("msgTitle", message: dictdata?.object(forKey: "msgBody") as! String,vc: self)
                        }
                    }
                    else{
                        Alert_view().error_Alert("Error", message: "Can't able to get data. Please try again.", vc: self)
                    }
                }
            }
        }
    }

    func getAssets(id:String) {
        
        StudioAPI().fetchBrandAssets(for: id) { (result) in
            switch result {
                  case .success(let token):
                    print(token.media)
                    self.brandsAssets = token.media
                    DispatchQueue.main.sync {
                        self.collimgslider.reloadData()
                    }
                    return
                  case .failure(let error):
                    print(error)
                    return
            }
        }
        
    }

    func getBrands(isEdit:Bool) {
        if !isEdit{
            arrSelectedIndex.removeAll()
            brandsAssets?.removeAll()
            collimgslider.reloadData()
        }
        
          if brandsList != nil {
            viewAttachMedia.isHidden = false
            if !isEdit{
                self.tblBrands.isHidden = false
            }
            
          } else {
              let firstBrandFeedbackLoop: (Driver<StudioState>) -> Signal<StudioEvent> =
              react(request: {$0.shouldLoadFirstBrand}, effects: { _ in
                  return self.studioService
                      .fetchBrands()
                      .trackActivity(self.activityIndicator)
                      .map { result in
                          switch result {
                          case .success(let value):
                              print(value.brands?.data)
                              self.brandsList = value.brands?.data
                              DispatchQueue.main.async {
                                self.viewAttachMedia.isHidden = false
                                self.tblBrands.reloadData()
                                self.tblBrands.isHidden = false
                              }
                              return value
                          case .failure(let error):
                              throw error
                          }
                  }
                  .map { response in StudioEvent.initial(response) }
                  .asSignal(onErrorJustReturn: StudioEvent.error(StudioServiceError.emptyBrands))
              })
            
              let feedbackLoops: [(Driver<StudioState>) -> Signal<StudioEvent>] = [
                  firstBrandFeedbackLoop
              ]
              
              let viewModelState = Driver.system(initialState: StudioState.defaultState(nil),
              reduce: StudioState.reduce,
              feedback: feedbackLoops)

              viewModelState
                  .drive()
                  .disposed(by: disposeBag)
          }
      }
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return brandsAssets?.count ?? 0
    }
          
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collimgslider.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UICollectionViewCell
        let img = cell.contentView.viewWithTag(1) as! UIImageView
        img.image = UIImage(named: "emptyStudio")

        //let dic:Dictionary<String,Any> = arrimg[indexPath.row] as! Dictionary<String,Any>
        //let str = brandsAssets![indexPath.row].thumbnail
        
        if let fullURL = URL(string:BRXNDBaseURL.url.absoluteString + brandsAssets![indexPath.row].thumbnail!) {
          let options = ImageLoadingOptions(
                               placeholder: UIImage(named: "emptyStudio"),
                                failureImage: UIImage(named: "emptyStudio"),
                contentModes: .init(success: .scaleAspectFill, failure: .scaleAspectFit, placeholder: .scaleAspectFit)
            )
          let req = ImageRequest(url: fullURL)
            Nuke.loadImage(with: req, options: options, into: (cell.contentView.viewWithTag(1) as! UIImageView))
        }
        if arrSelectedIndex.contains(indexPath){
            img.alpha = 1.0
        }
        else{
            img.alpha = 0.5
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if arrSelectedIndex.contains(indexPath) {
            arrSelectedIndex = arrSelectedIndex.filter { $0 != indexPath}
           // arrSelectedData = arrSelectedData.filter { $0 != strData}
        }
        else {
            arrSelectedIndex.append(indexPath)
           // arrSelectedData.append(strData)
        }
        
        collimgslider.reloadData()
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
