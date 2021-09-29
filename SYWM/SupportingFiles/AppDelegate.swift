//
//  AppDelegate.swift
//  SYWM
//
//  Created by Maninder Singh on 02/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import Firebase
import FirebaseAuth
import UserNotifications
import GoogleSignIn
import SquareInAppPaymentsSDK
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseMessaging
import AuthenticationServices
import AppTrackingTransparency




var isPushReceived = false
var app: UIApplication {
    return UIApplication.shared
}

var applicationStateString: String {
    if UIApplication.shared.applicationState == .active {
        return "active"
    } else if UIApplication.shared.applicationState == .background {
        return "background"
    }else {
        return "inactive"
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var push : PushPopUp?

    let locationManager = CLLocationManager()
    var currentLatLong = CLLocation(latitude: 0.0, longitude: 0.0)


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set your Square Application ID
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: "000590.3c26ad22bc6444eab04fe72f6489ecaf.1428") { (credentialState, error) in
                switch credentialState {
                    
                case .authorized:
                    print("Authorised")
                    break // The Apple ID credential is valid.
                case .revoked, .notFound:
                    print("rewoked")
                    break
                    // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                    
                default:
                    break
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        SQIPInAppPaymentsSDK.squareApplicationID = Square.APPLICATION_ID
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        GIDSignIn.sharedInstance().clientID = GoogleSignInclientKey
        GMSPlacesClient.provideAPIKey(GoogleMapKey)
        GMSServices.provideAPIKey(GoogleMapKey)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(logoutFromApp), name: .logout, object: nil)
//        self.getSingleUser(id: 157, reqType: "MATCH_REQ")
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in }
            UNUserNotificationCenter.current().delegate = self
            app.registerForRemoteNotifications()
        } else if #available(iOS 9, *) {
            app.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            app.registerForRemoteNotifications()
        } else {
            app.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
//        self.setRootVC()
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                //you got permission to track
            })
        } else {
            //you got permission to track, iOS 14 is not yet installed
        }
        return true
    }
    
    
    func createNewValues() {
        
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "fb719296655106493"{
            let sourceApplication: String? = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
            return ApplicationDelegate.shared.application(app, open: url, sourceApplication: sourceApplication, annotation: nil)
        }else{
            let sourceApplication: String? = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
//            return GIDSignIn.sharedInstance()?.handle(url, sourceApplication: sourceApplication, annotation: nil) ?? false
            return GIDSignIn.sharedInstance().handle(url)

        }
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func setRootVC(){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let nvc = storyBoard.instantiateViewController(withIdentifier: "NVC") as! UINavigationController
        if DataManager.accessToken == nil  {
            print("No token")
            let VC = storyBoard.instantiateViewController(withIdentifier: "OnBoardingVC") as! OnBoardingVC
            nvc.viewControllers = [VC]
            self.window?.rootViewController = nvc
            self.window?.makeKeyAndVisible()
        }else{
            print("Have token")
            let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            nvc.viewControllers = [VC]
            self.window?.rootViewController = nvc
            self.window?.makeKeyAndVisible()
        }
    }
    @objc func logoutFromApp(){
        DataManager.accessToken = nil
        UserVM.shared.userDict = nil
        let nvc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NVC") as! UINavigationController
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        nvc.viewControllers = [VC]
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nvc
        (UIApplication.shared.delegate as! AppDelegate).window?.makeKey()
    }
}


extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLatLong = location
            //                locationManager.stopUpdatingLocation()
        }
    }
}


extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print(fcmToken)
        DataManager.deviceToken = fcmToken
        NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken)")
    }
    
    // iOS9, called when presenting notification in foreground
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("[RemoteNotification] applicationState: \(applicationStateString) didReceiveRemoteNotification for iOS9: \(userInfo)")
        if UIApplication.shared.applicationState == .active {
            //TODO: Handle foreground notification
        } else {
            //TODO: Handle background notification
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(deviceTokenString)")
        NSLog("\(deviceTokenString)------dt")
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("failed to register \(error)")
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate,NotificationButtonTappedDelegate {
    
    // MARK: - Properties
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("\(userInfo)->in active data")
        let title = userInfo["title"] as? String ?? ""
        let message = userInfo["message"] as? String ?? ""
        let type = userInfo["type"] as? String ?? ""  ///EVT_JOIN //MATCH_REQ //CHT_MSG //MATCHED
//        let refId = userInfo["refId"] as? String ?? ""
        if type == "CHT_MSG"{
            if let root = self.window!.rootViewController as? UINavigationController {
                if let topVC = root.topViewController{
                    if topVC.isKind(of: ChatVC.self){
                        let id = (topVC as! ChatVC).chats.id
                        if let extra = userInfo["extra"] as? String{
                            if let dict = parseDataFromString(string: extra){
                                let messageDetail = UserVM.shared.parseChatSingleMessage(data: dict)
                                if id == messageDetail.chatId{
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NEWMESSAGE"), object: messageDetail)
                                }else{
                                    self.push = PushPopUp.init(title: title, message: message ,userInfo: userInfo)
                                    self.push?.delgate = self
                                }
                            }
                        }
                        
                    }else{
                        self.push = PushPopUp.init(title: title, message: message ,userInfo: userInfo)
                        self.push?.delgate = self
                    }
                    
                }
            }
        } else if type == "MATCH_REQ"{
            
        }else{
            self.push = PushPopUp.init(title: title, message: message ,userInfo: userInfo)
            self.push?.delgate = self
        }

        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        let userInfo = response.notification.request.content.userInfo
//        if isPushReceived{
//
//        }else{
            buttonPressed(userInfo: userInfo)
//        }
    }
    
    
    func buttonPressed(userInfo: [AnyHashable : Any]) {
        
        let pushType = userInfo["type"] as? String ?? ""
        if pushType == "EVT_JOIN"{
            if let root = self.window!.rootViewController as? UINavigationController {
                let VC = UIStoryboard.init(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SwymerVC") as! SwymerVC
                let refId = userInfo["refId"] as? String ?? "0"
                VC.poolId = Int(refId) ?? 0
                root.pushViewController(VC, animated: true)
            }
        }
        if pushType == "MATCH_REQ"{
            let refId = userInfo["refId"] as? String ?? "0"
            self.getSingleUser(id: Int(refId) ?? 0, reqType: "MATCH_REQ")
        }
        if pushType == "CHT_MSG"{
            if let root = self.window!.rootViewController as? UINavigationController {
                if let topVC = root.topViewController{
                    if topVC.isKind(of: ChatVC.self){
                        let id = (topVC as! ChatVC).chats.id
                        if let extra = userInfo["extra"] as? String{
                            if let dict = parseDataFromString(string: extra){
                                let messageDetail = UserVM.shared.parseChatSingleMessage(data: dict)
                                if id == messageDetail.chatId{
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NEWMESSAGE"), object: messageDetail)
                                }else{
                                    let VC = UIStoryboard.init(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                                    
                                    if let extra = userInfo["extra"] as? String{
                                        if let dict = parseDataFromString(string: extra){
                                            let messageDetail = UserVM.shared.parseMessageToOpenChatSCreen(data: dict)
                                            VC.chats = messageDetail
                                        }
                                    }
                                    root.pushViewController(VC, animated: true)
                                }
                            }
                        }
                        
                    }else{
                        let VC = UIStoryboard.init(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                        
                        if let extra = userInfo["extra"] as? String{
                            if let dict = parseDataFromString(string: extra){
                                let messageDetail = UserVM.shared.parseMessageToOpenChatSCreen(data: dict)
                                VC.chats = messageDetail
                            }
                        }
                        root.pushViewController(VC, animated: true)
                    }
                    
                }
            }
        }
        
        if pushType == "MATCHED"{
            let refId = userInfo["refId"] as? String ?? "0"
            self.getSingleUserProfile(id: Int(refId) ?? 0)
        }
        
        
    }
    
    func parseDataFromString(string :  String) -> JSONDictionary?{
        let data = string.data(using: .utf8)!
        if let jsonArray = try? JSONSerialization.jsonObject(with: data, options : .allowFragments) as? JSONDictionary{
            print(jsonArray) // use the json here
            return jsonArray
        }else{
            return nil
        }
    }
    
    func getSingleUserProfile(id : Int){
        APIManager1.share.getOtherUserProfile(id: id, indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                return
            }
            if let detail = data as? NSDictionary{
                let user =  UserData(response: detail)
                if let root = self.window!.rootViewController as? UINavigationController {
                    let VC = UIStoryboard.init(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SwymerDetailVC") as! SwymerDetailVC
                    VC.connectionDetail = user
                    root.pushViewController(VC, animated: true)
                }
            }
           
        }
    }
    
    func getSingleUser(id :Int,reqType : String){
        APIManager1.share.singleConnection(id: id, indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                return
            }
            if let data1 = data as? JSONDictionary{
                let d = EventVM.shared.parseConnectionsReceive1(dataDict: data1)
                if reqType == "MATCH_REQ"{
                    print("JInkide... jinnkeee...")
                    if let root = self.window!.rootViewController as? UINavigationController {
                        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SwymerSingleVC") as! SwymerSingleVC
                        VC.currentUser = d.fromUser
                        root.pushViewController(VC, animated: true)
                    }
                }
            }
            
        }
    }
    
}


