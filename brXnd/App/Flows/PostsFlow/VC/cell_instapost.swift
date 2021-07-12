

import UIKit
import Nuke
import Device

class Cellinstapost: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var lblposttitle: UILabel!
    @IBOutlet weak var lbldate: UILabel!
    @IBOutlet weak var lbluser: UILabel!
    var cellheight:CGFloat = 150
    
    @IBOutlet weak var collimgslider: UICollectionView!
    @IBOutlet weak var viewimgslider: UIView!
    @IBOutlet weak var imgusr: UIImageView!
    
    var arrimg:Array = Array<Any>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collimgslider.delegate = self
        collimgslider.dataSource = self
     
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellheight*0.7, height: cellheight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        collimgslider!.collectionViewLayout = layout
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUsrimg(strPath:String){
          if let fullURL = URL(string: BRXNDBaseURL.url.absoluteString + strPath) {
              imgusr.backgroundColor = BRXNDColors.veryLightPink
              let options = ImageLoadingOptions(
                                  placeholder: UIImage(named: "defaultUser"),
                                  failureImage: UIImage(named: "defaultUser"),
                  contentModes: .init(success: .scaleAspectFill, failure: .scaleAspectFit, placeholder: .scaleAspectFit)
              )
              let req = ImageRequest(url: fullURL)
              Nuke.loadImage(with: req, options: options, into: imgusr)
          }
          else{
            imgusr.image = UIImage(named: "defaultUser")
            }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return arrimg.count
    }
      
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collimgslider.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UICollectionViewCell
        let img = cell.contentView.viewWithTag(1) as! UIImageView
        img.image = UIImage(named: "emptyStudio")
         
        let dic:Dictionary<String,Any> = arrimg[indexPath.row] as! Dictionary<String,Any>
        
        print(dic)
        if let fullURL = URL(string:dic["url"] as! String) {
              img.backgroundColor = BRXNDColors.veryLightPink
              
            let options = ImageLoadingOptions(
                                 placeholder: UIImage(named: "emptyStudio"),
                                  failureImage: UIImage(named: "emptyStudio"),
                  contentModes: .init(success: .scaleAspectFill, failure: .scaleAspectFit, placeholder: .scaleAspectFit)
              )
            let req = ImageRequest(url: fullURL)
            Nuke.loadImage(with: req, options: options, into: img)
          }

         return cell
    }

}
