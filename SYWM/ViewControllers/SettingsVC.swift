//
//  SettingsVC.swift
//  SYWM
//
//  Created by Maninder Singh on 16/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import SwiftRangeSlider
import NVActivityIndicatorView
import Alamofire

class SettingsVC: BaseVC {

    //MARK:- IBOutlets
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var poolSwitch: UISwitch!
    @IBOutlet weak var messageSwitch: UISwitch!
    @IBOutlet weak var matchSwitch: UISwitch!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var sliderView: RangeSlider!
    @IBOutlet weak var maxLbl: UILabel!
    
    //MARK:- Variables
    var activityData = ActivityData()
    var genderArray = [GenderData]()
    var selectedRow = 0
    var codePicker = UIPickerView()
    var selectedGender : GenderData?
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logAnalytics(id: FirebaseEvent.SETTINGS_CLICKED, parameters: nil)
        self.selectedGender = GenderData(raw: ["id":UserVM.shared.userDict?.genderId ?? 0,"name":UserVM.shared.userDict?.genderName ?? ""])
        self.genderTF.text = UserVM.shared.userDict?.genderName ?? ""
        self.getGender()
        self.genderTF.delegate = self
        self.genderTF.setLeftPaddingPoints(left: 10, right: 10)
    }
    
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        self.showAlert(message: "Are you sure you want to delete your account?", title: "", otherButtons: ["Yes":{_ in
            self.deleteAccount()
            }], cancelTitle: "No", cancelAction: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        self.showAlert(message: "Are you sure you want to logout?", title: "", otherButtons: ["Yes":{_ in
            DataManager.accessToken = nil
            UserVM.shared.userDict = nil
            let nvc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NVC") as! UINavigationController
            let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectionVC") as! SelectionVC
            nvc.viewControllers = [VC]
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nvc
            (UIApplication.shared.delegate as! AppDelegate).window?.makeKey()
            }], cancelTitle: "No", cancelAction: nil)
    }
    
    @IBAction func likeButton(_ sender: Any) {
        guard let url = URL(string: "https://www.facebook.com/Swymapp") else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func settingButton(_ sender: Any) {
        upDateSetting()
    }
    //MARK:- Custom Methods

    @IBAction func rangeSliderValuesChanged(_ rangeSlider: RangeSlider) {
        
        self.minLabel.text = "\(Int(rangeSlider.lowerValue))"
        self.maxLbl.text = "\(Int(rangeSlider.upperValue))"
    }
    
    
    func deleteAccount(){
        APIManager1.share.deleteAccount(Id: UserVM.shared.userDict?.id ?? 0, indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            DataManager.accessToken = nil
            UserVM.shared.userDict = nil
            let nvc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NVC") as! UINavigationController
            let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            nvc.viewControllers = [VC]
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = nvc
            (UIApplication.shared.delegate as! AppDelegate).window?.makeKey()
        }
       
    }
    
    func getGender(){
        APIManager1.share.getGender(indicatorReq: true, params: nil) { (data, error, serverError) in
            self.getSetting()
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.genderArray.removeAll()
            guard let data1 = data as? JSONArray else {
                return
            }
            for data2 in data1{
                self.genderArray.append(GenderData(raw: data2 as NSDictionary))
            }
            let filteredGenderArray = self.genderArray.filter{$0.id != 4}
            self.genderArray = filteredGenderArray
            self.codePicker.reloadAllComponents()
        }
        
    }
    
    
    func getSetting(){
        
        APIManager1.share.getSettings(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if let responseDict = data as? JSONDictionary{
                let matchNotification = responseDict["matchNotification"] as? Bool ?? false
                self.matchSwitch.setOn(matchNotification, animated: true)
                let messageNotification = responseDict["messageNotification"] as? Bool ?? false
                self.messageSwitch.setOn(messageNotification, animated: true)
                let poolNotification = responseDict["poolNotification"] as? Bool ?? false
                self.poolSwitch.setOn(poolNotification, animated: true)
                let minAge = responseDict["minAge"] as? Int ?? 0
                let maxAge = responseDict["maxAge"] as? Int ?? 0
                self.maxLbl.text = "\(maxAge)"
                self.minLabel.text = "\(minAge)"
                self.sliderView.upperValue = Double(maxAge)
                self.sliderView.lowerValue = Double(minAge)
                if let interestedIn = responseDict["interestedIn"] as? NSDictionary{
                    self.selectedGender = GenderData(raw: interestedIn)
                    self.genderTF.text = self.selectedGender?.name
                }
                
            }
        }
       
    }
    
    func upDateSetting(){
        if self.genderArray.count == 0{
            self.showAlert(message: "Please add you interestes")
            return
        }
        let dict = ["id":self.genderArray[selectedRow].id]
        
        let params = [ "interestedIn": self.genderArray[selectedRow].id,
                      "locationService": true,
                      "notificationSound": true,
                      "notificationVibrate": true,
                      "matchNotification" : self.matchSwitch.isOn,
                      "maxAge" : Int(self.sliderView.upperValue),
                      "minAge" : Int(self.sliderView.lowerValue),
                      "messageNotification":self.messageSwitch.isOn,
                      "poolNotification":self.poolSwitch.isOn] as [String : Any]
        
        
        APIManager1.share.updateSettings(indicatorReq: true, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.navigationController?.popViewController(animated: true)
        }

    }
    
    
}

extension SettingsVC : UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        addPicker(field: textField)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.genderTF.text = genderArray[selectedRow].name
        self.selectedGender = genderArray[selectedRow]
    }
    
    func addPicker(field : UITextField){
        
        let inputView = UIView(frame: CGRect(x: 0,y: 0, width: self.view.frame.width, height: 200))
        codePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
        codePicker.tag = field.tag
        codePicker.dataSource = self
        codePicker.delegate = self
        
        codePicker.showsSelectionIndicator = true
        inputView.addSubview(codePicker)
        codePicker.reloadAllComponents()
        field.inputView = inputView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genderArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genderArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRow = row
    }
}
