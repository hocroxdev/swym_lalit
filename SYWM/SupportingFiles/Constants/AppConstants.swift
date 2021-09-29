//
//  AppConstant.swift
//  FriendsApp
//
//  Created by Maninder Singh on 21/10/17.
//  Copyright © 2017 ManinderBindra. All rights reserved.
//
import Foundation
//****************************   MARK: Data Manager Constants    ***********************
let kUserId = "userId"
let kUserName = "userName"
let kFirstName = "firstName"
let kLastName = "lastName"
let kPhoneNumber = "phoneNumber"
let kUserEmail = "userEmail"
let kAccessToken = "accessToken"
let kMessage = "message"
let kDeviceToken = "deviceToken"


//****************************   MARK: Common Constants    ***********************
var kBusinessId = ""
var kBusinessName = "DailyApp"
var kLanguageId = "5e11c1395340093fd97fe4be"
var kAppVersion = 1
var kDeviceType = "IOS"
var kSelectedDeliveryRegion = DeliveryRegion()

//let BASE_API_URL = "https://api.swymapp.com/"
let BASE_API_URL = "https://api.swymapp-dev.com/"

//let BASE_API_URL = "http://104.248.254.54:8080/"

//let BASE_API_URL = "http://127.0.0.1:8080/"

let GoogleMapKey = "AIzaSyAR4HpgDSVIWbzN61ASTGlImfdnVpkE-YU"
let GoogleSignInclientKey = "482235049781-rffmjokratt1mbncs35mv52lnfrqhdvk.apps.googleusercontent.com"

struct ApplePay {
     static let MERCHANT_IDENTIFIER: String = "merchant.com.swymapp"
     static let COUNTRY_CODE: String = "US"
     static let CURRENCY_CODE: String = "USD"
 }

 struct Square {
    
// ..........................DEV......................................................
//     static let SQUARE_LOCATION_ID: String = "LH3C1815W9351"
//     static let APPLICATION_ID: String  = "sandbox-sq0idb-b1yfeeO3eKJBo85IQU-nMA"
//     static let CHARGE_SERVER_HOST: String = "https://swym-payment.herokuapp.com"
//     static let CHARGE_URL: String = "\(CHARGE_SERVER_HOST)/chargeForSWYMPoolEvent"
    
//...........................PRODUCTION......................................
    
    static let SQUARE_LOCATION_ID: String = "LH3C1815W9351"
    static let APPLICATION_ID: String  = "sq0idp-qJpqGqWs932qpdErVKoURw"
    static let CHARGE_URL: String = "\(BASE_API_URL)api/payment/square/create-event"
 }


//http://13.233.104.239:7000/documentation
