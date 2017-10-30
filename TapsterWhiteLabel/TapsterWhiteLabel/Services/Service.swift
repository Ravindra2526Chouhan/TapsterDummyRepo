//
//  Service.swift
//  PostCard
//
//  Created by Mac on 21/04/17.
//  Copyright © 2017 Linkites. All rights reserved.
//

import Foundation
import Alamofire

struct Service {
    
    static let service = Service()
    
    func getAuthHeaders() -> HTTPHeaders {
        if(User.currentUser.isLogin) {
            let headers: HTTPHeaders = [
                "Authorization": User.currentUser.authToken,
                "deviceToken":User.currentUser.deviceToken,
                "deviceType":"iOS",
                "env":User.currentUser.environment,
                "vendorGroupId":User.currentUser.vendorGroupId,
                "Accept": "application/json"
            ]
            return headers
        }
        else {
            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "deviceType":"iOS",
                "env":User.currentUser.environment,
                "vendorGroupId":User.currentUser.vendorGroupId
            ]
            return headers
        }
    }
    
    func get(url:String,completion:@escaping (_ result: AnyObject) -> Void) {
        
        Alamofire.request(url, headers:self.getAuthHeaders()).responseJSON { response in
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                completion(JSON)
            }
            if let result = response.result.error {
                completion(result as AnyObject)
            }
        }
    }
    
    func get_using_no_auth(url:String,completion:@escaping (_ result: AnyObject) -> Void) {
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                completion(JSON)
            }
            if let result = response.result.error {
                completion(result as AnyObject)
            }
        }
    }
    //post data to service
    func post(url:String, parameters:Parameters,completion:@escaping (_ result: AnyObject) -> Void) {
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:self.getAuthHeaders()).responseJSON { (response) in
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                completion(JSON)
            }
            if let result = response.result.error {
                completion(result as AnyObject)
            }
        }
    }
    //put data to service
    func put(url:String, parameters:Parameters,completion:@escaping (_ result: AnyObject) -> Void) {
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers:self.getAuthHeaders()).responseJSON { (response) in
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                completion(JSON)
            }
            if let result = response.result.error {
                completion(result as AnyObject)
            }
        }
    }
    //delete data to service
    func del(url:String, parameters:Parameters,completion:@escaping (_ result: AnyObject) -> Void) {
        Alamofire.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers:self.getAuthHeaders()).responseJSON { (response) in
            print(response.result)   // result of response serialization
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                completion(JSON)
            }
            if let result = response.result.error {
                completion(result as AnyObject)
            }
        }
    }
    
    func delCreditCard(url:String, completion:@escaping (_ result: AnyObject) -> Void) {
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers:self.getAuthHeaders()).responseJSON { (response) in
            print(response.result)   // result of response serialization
            if let result = response.result.value {
                let JSON = result as! NSDictionary
                completion(JSON)
            }
            if let result = response.result.error {
                completion(result as AnyObject)
            }
        }
    }

}
