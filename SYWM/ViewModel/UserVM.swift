//
//  UserVM.swift
//  FriendsApp
//
//  Created by Maninder Singh on 21/10/17.
//  Copyright © 2017 ManinderBindra. All rights reserved.
//

import Foundation
import CoreLocation

class UserVM{
    
    private init(){}
    static let shared = UserVM()
    
    var userDict : UserData?
    
    //MARK: User Methods
  
    func login(username: String, password: String, response: @escaping responseCallBack){
        APIManager.login(username: username, password: password, successCallback: { (responseDict,data)  in
            DataManager.accessToken = responseDict?["id_token"] as? String ?? ""
            response(true,nil, nil)
        }) { (errorReason, error) in
            switch errorReason!{
            case .InternetNotReachable:
                response(false, error?.localizedDescription ?? "", error)
                
            default:
                response(false, error?.userInfo["detail"] as? String ?? "", error)
            }
        }
    }
    
    func signUp(firstName: String,lastName: String,email: String, password: String,login: String ,response: @escaping responseCallBack){
        APIManager.signUp(firstName: firstName, lastName: lastName, email: email, password: password, login: login, successCallback: { (responseDict,data)  in
            DataManager.accessToken = responseDict?["id_token"] as? String ?? ""
            response(true,nil, nil)
        }) { (errorReason, error) in
            switch errorReason!{
            case .InternetNotReachable:
                response(false, error?.localizedDescription ?? "", error)
                
            default:
                response(false, error?.userInfo["detail"] as? String ?? "", error)
            }
        }
    }
    
    func getUser(login: String ,response: @escaping responseCallBack){
        APIManager.getUser(login: login, successCallback: { (responseDict,data)  in
            self.userDict = UserData(response: responseDict as! NSDictionary)
            response(true, nil, nil)
        }) { (errorReason, error) in
            switch errorReason!{
            case .InternetNotReachable:
                response(false, error?.localizedDescription ?? "", error)
                
            default:
                response(false, error?.userInfo["detail"] as? String ?? "", error)
            }
        }
    }

  
}
