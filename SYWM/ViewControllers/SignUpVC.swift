//
//  SignUpVC.swift
//  SYWM
//
//  Created by Maninder Singh on 02/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit

class SignUpVC: BaseVC {

    
    //MARK:- IBOutlets
    @IBOutlet weak var firstNameTF: UITextField!
    
    @IBOutlet weak var lastNameTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var confirmTF: UITextField!
    
    @IBOutlet weak var countryTF: UITextField!
    
    @IBOutlet weak var iphoneTF: UITextField!
    
    @IBOutlet weak var userNameTF: UITextField!
    //MARK:- Variables
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalytics(id: FirebaseEvent.SIGN_UP, parameters: nil)
        self.firstNameTF.setLeftPaddingPoints(left: 10, right: 10)
        self.lastNameTF.setLeftPaddingPoints(left: 10, right: 10)
        self.emailTF.setLeftPaddingPoints(left: 10, right: 10)
        self.passwordTF.setLeftPaddingPoints(left: 10, right: 10)
        self.confirmTF.setLeftPaddingPoints(left: 10, right: 10)
        self.userNameTF.setLeftPaddingPoints(left: 10, right: 10)
        self.iphoneTF.setLeftPaddingPoints(left: 10, right: 10)
        
        
    }
    
    //MARK:- IBActions
    
    @IBAction func submitBUtton(_ sender: Any) {
        self.logAnalytics(id: FirebaseEvent.SIGN_UP_CLICKED, parameters: nil)
        if firstNameTF.isEmpty{
            self.showAlert(message: "Please enter firstname.")
            return
        }
        if lastNameTF.isEmpty{
            self.showAlert(message: "Please enter lastname.")
            return
        }
//        if userNameTF.isEmpty{
//            self.showAlert(message: "Please enter username.")
//            return
//        }
        if emailTF.isEmpty{
            self.showAlert(message: "Please enter email address.")
            return
        }
        if !emailTF.isValidEmail{
            self.showAlert(message: "Please enter valid email address.")
            return
        }
        if passwordTF.isEmpty{
            self.showAlert(message: "Please enter password.")
            return
        }
        if confirmTF.isEmpty{
            self.showAlert(message: "Please enter confirm password.")
            return
        }
        if passwordTF.text != confirmTF.text{
            self.showAlert(message: "Password and confirm password do not matched.")
            return
        }
        self.view.endEditing(true)
        signup()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:- Custom Methods
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

extension SignUpVC{
    
    func signup(){
        UserVM.shared.signUp(firstName: self.firstNameTF.text ?? "", lastName: self.lastNameTF.text ?? "", email: emailTF.text ?? "", password: passwordTF.text ?? "", login: emailTF.text ?? "") { (success, message, error) in
            if success{
                self.logAnalytics(id: FirebaseEvent.SIGN_UP_COMPLETE, parameters: nil)
                self.registerApi()
                let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                VC.isSignupFlow = true
                self.navigationController?.pushViewController(VC, animated: true)

            }else{
                self.showAlert(message: message, title: error?.userInfo["title"] as? String ?? "", otherButtons: nil, cancelTitle: "Ok", cancelAction: nil)
            }
        }
        
    }
    
}


extension SignUpVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTF{
            lastNameTF.becomeFirstResponder()
        }
        if textField == lastNameTF{
            userNameTF.becomeFirstResponder()
        }
//        if textField == userNameTF{
//            emailTF.becomeFirstResponder()
//        }
        if textField == emailTF{
            passwordTF.becomeFirstResponder()
        }
        if textField == passwordTF{
            confirmTF.becomeFirstResponder()
        }
        if textField == confirmTF{
            confirmTF.resignFirstResponder()
        }
        return true
    }
    
}
