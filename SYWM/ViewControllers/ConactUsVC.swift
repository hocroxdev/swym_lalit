//
//  ConactUsVC.swift
//  SYWM
//
//  Created by Maninder Singh on 16/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import  GrowingTextView
import NVActivityIndicatorView
import Alamofire

class ConactUsVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var detailTV: GrowingTextView!
    
    //MARK:- Variables
    var activityData = ActivityData()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logAnalytics(id: FirebaseEvent.CONTACT_US, parameters: nil)
    }
    
    //MARK:- IBActions
    @IBAction func sendButton(_ sender: Any) {
        let VC = UIStoryboard.init(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SwymerVC") as! SwymerVC
        self.navigationController?.pushViewController(VC, animated: true)
//        if detailTV.text.count == 0{
//            self.showAlert(message: "Please enter detail about your concern.")
//            return
//        }
//        asktFAQs()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Custom Methods

    func asktFAQs(){
        let params = ["text" : self.detailTV.text!] as [String : Any]
        APIManager1.share.askFAQ(indicatorReq: true, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if let jsonDict = data as? JSONDictionary{
                self.detailTV.text = ""
                self.showAlert(message: jsonDict["reason"] as? String ?? "")
                
            }
        }
    }
}
