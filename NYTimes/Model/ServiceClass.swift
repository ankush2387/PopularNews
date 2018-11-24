//
//  ServiceClass.swift
//  NYTimes
//
//  Created by CHETUMAC043 on 11/20/18.
//  Copyright © 2018 CHETUMAC043. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol ClassServiceDelegate {
    func getResponse(response:Dictionary<String,Any>)
    func getError(error:String)
    @objc optional func resetPassword(status:Int,message:String)
}

class ServiceClass: NSObject {
    
    var delegate: ClassServiceDelegate?
    
    func callAPI(url: String,dictionary: NSDictionary) {
        
        if  let url = URL(string: url) {
            debugPrint(url)
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData , timeoutInterval: 90)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "accept")
            request.setValue("ef848ca1c21741969bb0459ca8542b65", forHTTPHeaderField: "api-key")
            request.httpMethod = "Get"
       
            Alamofire.request(request)
                .responseString { response in
                    guard response.error == nil else{
                        // error handling
                        self.delegate?.getError(error: (response.error?.localizedDescription ?? ""))
                        return
                    }
                    debugPrint(response.value! as Any)
                    // success response handling
                    if let dataResponse = response.value?.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: dataResponse, options: []) as! [String: Any]
                            guard  json["status"] as? String  == "OK" else  {
                                // error handling
                                Loader.hide()
                                self.delegate?.getError(error: "error occured")
                                return
                            }
                            self.delegate?.getResponse(response: json)
                        } catch let error as NSError {
                            Loader.hide()
                            self.delegate?.getError(error: (error.localizedDescription))
                        }
                        
                    }
            }
        }
    }

}
