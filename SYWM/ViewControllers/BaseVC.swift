//
//  BaseVC.swift
//  FriendsApp
//
//  Created by Maninder Singh on 21/10/17.
//  Copyright © 2017 ManinderBindra. All rights reserved.
//

import UIKit
import MessageUI
import Firebase



class BaseVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: *************   Show Alert   ***************
    func showAlert(message: String?, title:String = "Information", otherButtons:[String:((UIAlertAction)-> ())]? = nil, cancelTitle: String = "OK", cancelAction: ((UIAlertAction)-> ())? = nil) {
        let newTitle = title.capitalized
        let newMessage = message
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction))
        
        if otherButtons != nil {
            for key in otherButtons!.keys {
                alert.addAction(UIAlertAction(title: key, style: .default, handler: otherButtons![key]))
            }
        }
        present(alert, animated: true, completion: nil)
    }
    
    func showErrorMessage(error: NSError?, cancelAction: ((UIAlertAction)-> ())? = nil) {
        var title = "Error"
        var message = "Something Went Wrong"
        if error != nil {
            title = error!.domain
            message = error!.userInfo["message"] as? String ?? ""
        }
        let newTitle = title.capitalized
        let newMessage = message.capitalized
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: cancelAction))
        present(alert, animated: true, completion: nil)
    }
    
    func openMailApp(email:String = "", subject:String = "", body:String = ""){
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject)") {
           if #available(iOS 10.0, *) {
             UIApplication.shared.open(url)
           } else {
             UIApplication.shared.openURL(url)
           }
         }
    }
    
    func sendEmail(email:String = "", subject:String = "", body:String = "") {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setSubject(subject)
            present(mail, animated: true)
        } else {
            // show failure alert
              print("This device is not configured to send email. Please set up an email account.")
            self.showAlert(message: "This device is not configured to send email. Please set up an email account.", title: "", otherButtons: nil, cancelTitle: "OK") { action in
                
            }
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func logAnalytics(id:String, parameters: [String: Any]?){
        Analytics.logEvent(id, parameters: parameters)
    }
}

