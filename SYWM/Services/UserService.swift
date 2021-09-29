//
//  UserService.swift
//  Dailyuse
//
//  Created by Maninder Singh on 12/02/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import Foundation
enum UserServices: APIService{
    case Login(username: String, password: String)
    case SignUp(firstName: String,lastName: String,password: String,email:String,login : String)
    case GetUser(login: String)
    
    var path: String {
        var path = ""
        switch self {
        case .Login:
            path = BASE_API_URL.appending("api/authenticate")
            
        case .SignUp:
            path = BASE_API_URL.appending("api/register")
            
        case .GetUser:
            path = BASE_API_URL.appending("api/user-profiles/me")
       
        }
        return path
    }
    
    var resource: Resource {
        var resource: Resource!
        switch self {

        case let .Login(username, password):
            var parametersDict = JSONDictionary()
            parametersDict["username"] = username
            parametersDict["password"] = password
            parametersDict["rememberMe"] = true
            resource = Resource(method: .post, parameters: parametersDict, headers: nil)
            
        case let .SignUp(firstName, lastName,password,email,login):
            var parametersDict = JSONDictionary()
            parametersDict["firstName"] = firstName
            parametersDict["lastName"] = lastName
            parametersDict["password"] = password
            parametersDict["email"] = email
            parametersDict["login"] = login
            parametersDict["langKey"] = "en_US"
            resource = Resource(method: .post, parameters: parametersDict, headers: nil)
            
        case let .GetUser(login):
            var parametersDict = JSONDictionary()
//            parametersDict["login"] = login
            let header = ["Authorization" : "Bearer " + (DataManager.accessToken ?? "")]
            resource = Resource(method: .get, parameters: parametersDict, headers: header)
            

        }
        return resource
    }
}


extension APIManager {
    
 
    
    class func login(username: String, password: String, successCallback: @escaping JSONDictionaryResponseCallback, failureCallback: @escaping APIServiceFailureCallback){
        UserServices.Login(username: username, password: password).request(success: { (response,data) in
            if let responseDict = response as? JSONDictionary {
                successCallback(responseDict, data)
            }
            else {
                successCallback([:], data)
            }
        }, failure: failureCallback)
    }
    
    class func signUp(firstName: String,lastName: String ,email: String,password: String, login: String,successCallback: @escaping JSONDictionaryResponseCallback, failureCallback: @escaping APIServiceFailureCallback){
        UserServices.SignUp(firstName: firstName, lastName: lastName,password: password, email:email, login: login).request(success: { (response,data) in
            if let responseDict = response as? JSONDictionary {
                successCallback(responseDict, data)
            }
            else {
                successCallback([:], data)
            }
        }, failure: failureCallback)
    }
    
    class func getUser(login: String,successCallback: @escaping JSONDictionaryResponseCallback, failureCallback: @escaping APIServiceFailureCallback){
        UserServices.GetUser(login: login).request(success: { (response,data) in
            if let responseDict = response as? JSONDictionary {
                successCallback(responseDict, data)
            }
            else {
                successCallback([:], data)
            }
        }, failure: failureCallback)
    }
    
  
 
}
