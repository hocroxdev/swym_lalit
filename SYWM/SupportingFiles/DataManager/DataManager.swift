//
//  DataManager.swift
//  FriendsApp
//
//  Created by Maninder Singh on 21/10/17.
//  Copyright © 2017 ManinderBindra. All rights reserved.
//

import Foundation
class DataManager{
    
    static var userId:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kUserId)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kUserId)
        }
    }
    
    static var deviceToken:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kDeviceToken)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kDeviceToken)
        }
    }
    
    static var userName:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kUserName)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kUserName)
        }
    }
    
    static var phoneNumber:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kPhoneNumber)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kPhoneNumber)
        }
    }
    
    static var firstName:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kFirstName)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kFirstName)
        }
    }
    
    static var lastname:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kLastName)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kLastName)
        }
    }
    
    static var email:String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kUserEmail)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: kUserEmail)
        }
    }
    
    
    static var accessToken: String?{
        set{
            UserDefaults.standard.setValue(newValue, forKey: kAccessToken)
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: kAccessToken)
        }
    }
    
}

