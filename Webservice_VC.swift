
import UIKit

class Webservice_VC: NSObject {
    func call_webservice_get(view_load:UIView,str_URL:String,dict_par:NSMutableDictionary,dict_header:NSMutableDictionary,handler:@escaping (Data?,Error?)-> ()) {
        
        let view_loading:UIView=UIView(frame:CGRect(x: 0, y: 0, width: view_load.frame.size.width, height: view_load.frame.size.height))
        view_loading.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view_load.addSubview(view_loading)
        
        let img_ldr:UIImageView=UIImageView(frame:CGRect(x: view_loading.center.x-25, y: view_loading.center.y-25, width: 50, height: 50))
        img_ldr.image = UIImage(named: "ldr")
        view_loading.addSubview(img_ldr)
        
        let kRotationAnimationKey = "com.myapplication.rotationanimationkey"
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float(M_PI * 2.0)
        rotationAnimation.duration = 0.5
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.isRemovedOnCompletion=false
        
        img_ldr.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
        
        let session = URLSession.shared
        
        var str_URL:String = str_URL
        var isFirst:Bool = true
        for (key, value) in dict_par {
            if isFirst{
                isFirst = false
                str_URL = "\(str_URL)\(key)=\(value)"
            }
            else{
                str_URL = "\(str_URL)&\(key)=\(value)"
            }
        }
       
        print(str_URL)
        
        
        var request = URLRequest(url: URL(string: str_URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        request.httpMethod = "GET"
        print("==============Header")
        for (key,value) in dict_header{
            print("\(key): \(value)")
            request.setValue(value as! String, forHTTPHeaderField: key as! String)
        }
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            
            DispatchQueue.main.sync {
                view_loading.isHidden=true
                view_loading.removeFromSuperview()
            }
            if data != nil{
                let convertedString = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                handler(data,error)
            }
            else{
                handler(data,error)
            }
        })
        
        task.resume()
        
    }
    
    func call_webservice_post(view_load:UIView,str_URL:String,dict_par:NSMutableDictionary,dict_header:NSMutableDictionary,handler:@escaping (Data?,Error?)-> ()) {
        
        let view_loading:UIView=UIView(frame:CGRect(x: 0, y: 0, width: view_load.frame.size.width, height: view_load.frame.size.height))
        view_loading.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view_load.addSubview(view_loading)
        
        let img_ldr:UIImageView=UIImageView(frame:CGRect(x: view_loading.center.x-25, y: view_loading.center.y-25, width: 50, height: 50))
        img_ldr.image = UIImage(named: "ldr")
        view_loading.addSubview(img_ldr)
        
        let kRotationAnimationKey = "com.myapplication.rotationanimationkey"
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float(M_PI * 2.0)
        rotationAnimation.duration = 0.5
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.isRemovedOnCompletion=false
        
        img_ldr.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
        
        let session = URLSession.shared
        
        do {
            print(dict_par)
            
            //let jsonData = try JSONSerialization.data(withJSONObject: dict_par, options: .prettyPrinted)
          
            var request = URLRequest(url: URL(string: str_URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            
            let postString = Webservice_VC.self.getPostString(params: dict_par)
            request.httpBody = postString.data(using: .utf8)
            
            for (key,value) in dict_header{
                print("\(key): \(value)")
                request.setValue(value as! String, forHTTPHeaderField: key as! String)
            }
            
            let task = session.dataTask(with: request, completionHandler: {
                (
                data, response, error) in
                DispatchQueue.main.sync {
                    view_loading.isHidden=true
                    view_loading.removeFromSuperview()
                }
                if data != nil{
                    let convertedString = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                    handler(data,error)
                }
                else{
                    handler(data,error)
                }
            })
            
            task.resume()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func getPostString(params:NSMutableDictionary) -> String
    {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key as! String + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    func call_webservice_post_json(view_load:UIView,str_URL:String,dict_par:NSMutableDictionary,dict_header:NSMutableDictionary,handler:@escaping (Data?,Error?)-> ()) {
        
        let view_loading:UIView=UIView(frame:CGRect(x: 0, y: 0, width: view_load.frame.size.width, height: view_load.frame.size.height))
        view_loading.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view_load.addSubview(view_loading)
        
        let img_ldr:UIImageView=UIImageView(frame:CGRect(x: view_loading.center.x-25, y: view_loading.center.y-25, width: 50, height: 50))
        img_ldr.image = UIImage(named: "ldr")
        view_loading.addSubview(img_ldr)
        
        let kRotationAnimationKey = "com.myapplication.rotationanimationkey"
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float(M_PI * 2.0)
        rotationAnimation.duration = 0.5
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.isRemovedOnCompletion=false
        
        img_ldr.layer.add(rotationAnimation, forKey: kRotationAnimationKey)
        
        let session = URLSession.shared
        
        do {
            print(dict_par)
            
            let jsonData = try JSONSerialization.data(withJSONObject: dict_par, options: .prettyPrinted)
          
            var request = URLRequest(url: URL(string: str_URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            
            print("==============Header")
            for (key,value) in dict_header{
                print("\(key): \(value)")
                request.setValue(value as! String, forHTTPHeaderField: key as! String)
            }
            
            request.httpBody = jsonData
            let task = session.dataTask(with: request, completionHandler: {
                (
                data, response, error) in
                
                
                DispatchQueue.main.sync {
                    view_loading.isHidden=true
                    view_loading.removeFromSuperview()
                }
                if data != nil{
                    let convertedString = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                    handler(data,error)
                }
                else{
                    handler(data,error)
                }
            })
            
            task.resume()
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
