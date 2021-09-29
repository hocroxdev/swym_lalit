//
//  LoginVC.swift
//  SYWM
//
//  Created by Maninder Singh on 02/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import NVActivityIndicatorView
import AuthenticationServices


class LoginVC: BaseVC,NVActivityIndicatorViewable {
    //MARK:- IBOutlets
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var privacytextView: UITextView!
    
    //MARK:- Variables
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logAnalytics(id: FirebaseEvent.LOGIN, parameters: nil)
        userNameTF.setLeftPaddingPoints(left: 10, right: 10)
        passwordTF.setLeftPaddingPoints(left: 10, right: 10)
        
        let linkedText = NSMutableAttributedString(attributedString: privacytextView.attributedText)
        let hyperlinked = linkedText.setAsLink(textToFind: "Privacy Policy", linkURL: "https://s3.amazonaws.com/static.swymapp.com/privacy.html")
        _ = linkedText.setAsLink(textToFind: "Terms of Service", linkURL: "https://s3.amazonaws.com/static.swymapp.com/tos.html")
                
        if hyperlinked {
              privacytextView.attributedText = NSAttributedString(attributedString: linkedText)
        }
        
        if #available(iOS 13.0, *) {
            let button = ASAuthorizationAppleIDButton()
            button.addTarget(self, action: #selector(appleLoginClicked), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        } else {
                   // Fallback on earlier versions
        }
    }
    
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        logAnalytics(id: "Login_back_click", parameters: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func eyeButton(_ sender: Any) {
        logAnalytics(id: "Login_eye_Button_click", parameters: nil)
        self.eyeButton.isSelected = !self.eyeButton.isSelected
        if self.eyeButton.isSelected{
            self.passwordTF.isSecureTextEntry = false
        }else{
            self.passwordTF.isSecureTextEntry = true
        }
    }
    
    
    @IBAction func signInButton(_ sender: Any) {
        self.logAnalytics(id: FirebaseEvent.LOGIN_CLICKED, parameters: nil)
        if userNameTF.isEmpty{
            self.showAlert(message: "Please enter username.")
            return
        }
        if passwordTF.isEmpty{
            self.showAlert(message: "Please enter password.")
            return
        }
        self.view.endEditing(true)
        login()
    }
    
    @IBAction func facebookButton(_ sender: Any) {
        logAnalytics(id: "facebookButton_click", parameters: nil)
        facebookData()
    }
    
    @IBAction func moveToSignUpButton(_ sender: Any) {
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func googleButton(_ sender: Any) {
        logAnalytics(id: "SignIN_googleButton_click", parameters: nil)
//        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    //MARK:- Custom Methods

    
    func facebookData() {
        LoginManager().logOut()
        LoginManager().logIn(permissions: ["public_profile","email"], from: self) { (result, error) in
            if error == nil{
                if let fbResult = result{
                    if fbResult.isCancelled == false{
                        self.getFBUserData()
                    }
                }else{
                    self.showAlert(message: "Please try again.".localize())
                }
            }else{
                self.showAlert(message: error?.localizedDescription ?? "")
            }
        }
    }
    
    func getFBUserData(){
        self.startAnimating()
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id,name ,email"]).start(completionHandler: { (connection, result, error) -> Void in
                self.stopAnimating()
                if (error == nil){
                    if let resultDict = result as? NSDictionary{
                        let id =  resultDict["id"] as? String ?? ""
                        let access = AccessToken.current?.tokenString ?? ""
                        if id == ""{
                            self.showAlert(message: "We doesn't get your email from facebook.")
                            return
                        }
                        self.loginSocail(accessToken: access, email: id, loginType: "FACEBOOK")
                    }else{
                        self.showAlert(message: "Please try again.".localize())
                    }
                }else{
                    self.showAlert(message: error?.localizedDescription ?? "")
                }
            })
        }
    }

    
    func loginSocail(accessToken : String, email: String,loginType: String){
        let params = ["accessToken" : accessToken,
                      "login": email]
        APIManager1.share.socailogin(loginType: loginType, indicatorReq: true, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.registerApi()
            self.checkProfile()
        }
    }
    
    func checkProfile(){
        APIManager1.share.getProfile(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                VC.isSignupFlow = true
                self.navigationController?.pushViewController(VC, animated: true)
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(VC, animated: true)
            
        }
    }
    
    func registerApi(){
        let params = ["deviceID" : DataManager.deviceToken ?? "",
                      "deviceName" : "Iphone",
                      "deviceType" : "IOS",
                      "messagingID" : DataManager.deviceToken ?? ""]
        APIManager1.share.registerDevice(indicatorReq: false, params: params) { (data, error, serverError) in
            print(data)
        }
    }
}

extension LoginVC : GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            signIn.signOut()
            guard let email = user.userID,  let accessToken = user.authentication.idToken else{
                self.showAlert(message: "Something went wrong.")
                return
            }
            self.loginSocail(accessToken: accessToken , email: email, loginType: "GOOGLE")
        } else {
            self.showAlert(message: error.localizedDescription)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        self.showAlert(message: error.localizedDescription)
    }
    
}


extension LoginVC{
    
    func login(){
        UserVM.shared.login(username: self.userNameTF.text ?? "", password: passwordTF.text ?? "") { (success, message, error) in
            
            if success{
                self.registerApi()
                let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(VC, animated: true)
            }else{
//                 It should work as the Android version does which says unable to login or let the user know these aren't correct details. 
                self.showAlert(message: "Unable to login..", title: "", otherButtons: nil, cancelTitle: "Ok", cancelAction: nil)
            }
            
        }
        
    }
    
}

extension LoginVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTF{
            passwordTF.becomeFirstResponder()
        }
        if textField == passwordTF{
            passwordTF.resignFirstResponder()
        }
        return true
    }
    
}
extension NSMutableAttributedString {
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            
           self.addAttribute(.link, value: linkURL, range: foundRange)
            
            return true
        }
        return false
    }
}


extension LoginVC :ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    
    @objc func appleLoginClicked(){
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
//            let authorizationCode = appleIDCredential.authorizationCode?.base64EncodedString(options: .lineLength64Characters)
            let authorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("userIdentifier: \(authorizationCode) fullName: \(fullName?.givenName ?? "") email: \(email)")
            loginApple(authorizationCode: authorizationCode ?? "", email: email ?? "", name: fullName?.givenName ?? "")
          
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            loginApple(authorizationCode: username, email: "", name: "")
            // For the purpose of this demo app, show the password credential as an alert.
            
        default:
            break
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
    @available(iOS 13.0, *)
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func loginApple(authorizationCode : String, email: String,name: String){
       
        let params = ["authorizationCode" : authorizationCode,
                      "email": email, "name":name]
        APIManager1.share.appleLogin(indicatorReq: true, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                     self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.registerApi()
            self.checkProfile()
            
        }
    }
}
