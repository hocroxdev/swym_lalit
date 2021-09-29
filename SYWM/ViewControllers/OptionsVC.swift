//
//  OptionsVC.swift
//  SYWM
//
//  Created by Maninder Singh on 05/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit

class OptionsVC: BaseVC {

    //MARK:- IBOutlets
    
    
    //MARK:- Variables
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func launchPoolButton(_ sender: Any) {
        self.logAnalytics(id: FirebaseEvent.SINGLE_POOL_CLICKED, parameters: nil)
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "LaunchPoolVC") as! LaunchPoolVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func editProfileButton(_ sender: Any) {
        self.logAnalytics(id: FirebaseEvent.EDIT_PROFILE_CLICKED, parameters: nil)
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func settingButton(_ sender: Any) {
        self.logAnalytics(id: FirebaseEvent.SETTINGS_CLICKED, parameters: nil)
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func faqButton(_ sender: Any) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func contactusButton(_ sender: Any) {
        self.logAnalytics(id: FirebaseEvent.CONTACT_US_CLICKED, parameters: nil)
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "ConactUsVC") as! ConactUsVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func aboutUsButton(_ sender: Any) {
        self.logAnalytics(id: FirebaseEvent.ABOUT_US_CLICKED, parameters: nil)
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
        VC.header = "About Us"
        VC.link = "https://s3.amazonaws.com/static.swymapp.com/about.html"
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func termsButton(_ sender: Any) {
        self.logAnalytics(id: FirebaseEvent.TERMS_CLICKED, parameters: nil)
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
        VC.header = "Terms of Service"
        VC.link = "https://s3.amazonaws.com/static.swymapp.com/tos.html"
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func privacyButton(_ sender: Any) {
        self.logAnalytics(id: FirebaseEvent.PRIVACY_CLICKED, parameters: nil)
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
        VC.header = "Privacy Policy"
        VC.link = "https://s3.amazonaws.com/static.swymapp.com/privacy.html"
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    //MARK:- Custom Methods


}
