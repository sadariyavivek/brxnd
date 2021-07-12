
import UIKit

class Alert_view: UIView {

    func error_Alert(_ title: String,message:String,vc:UIViewController){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        vc.present(alert, animated: true, completion: nil)
    }

}
