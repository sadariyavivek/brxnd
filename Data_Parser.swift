
import UIKit

class Data_Parser: NSObject {
    func call_webservice_dict_parse(vc:UIViewController,data:Data!) -> NSDictionary? {
        do {
            
            
            let JSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            
            guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                print("Not a Dictionary")
                // put in function
                
                return nil
            }
            
            return JSONDictionary
            
        }
            
        catch let JSONError as NSError {
            print("\(JSONError)")
            
            return nil
        }
    }
}
