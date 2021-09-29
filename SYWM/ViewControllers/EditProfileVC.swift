//
//  EditProfileVC.swift
//  SYWM
//
//  Created by Maninder Singh on 16/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import AVKit
import  Alamofire
import SDWebImage
import NVActivityIndicatorView
import SkyFloatingLabelTextField
import CropViewController
class EditProfileVC: BaseVC {
    //MARK:- IBOutlets
    
    @IBOutlet weak var image1: UIButton!
    @IBOutlet weak var image2: UIButton!
    @IBOutlet weak var image3: UIButton!
    @IBOutlet weak var aboutMeTV: UITextView!
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var jobTF: UITextField!
    @IBOutlet weak var companyTF: UITextField!
    @IBOutlet weak var educationTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var breakButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var brkTheIceView: UIView!
    
    //MARK:- Variables
    fileprivate let imagePicker = UIImagePickerController()
    var directory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
    var profilePath: String = ""
    var selectedImage = 0
    var codePicker = UIPickerView()
    var genderArray = [GenderData]()
    var educationArray = [GenderData]()
    var activityData = ActivityData()
    var selectedRow = 0
    var selectedEducation : GenderData?
    var selectedGender : GenderData?
    var heightInches = 48
    var serverPath = ""
    var serverKey = ""
    var isSignupFlow = false
    var images1 : UIImage? = nil
    var images2 : UIImage? = nil
    var images3 : UIImage? = nil
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logAnalytics(id: FirebaseEvent.UPDATE_PROFILE, parameters: nil)
        if isSignupFlow{
            self.brkTheIceView.isHidden = true
            self.backButton.isHidden = true
        }else{
            self.brkTheIceView.isHidden = false
            self.backButton.isHidden = false
        }
        phoneTF.setLeftPaddingPoints(left: 10, right: 10)
        jobTF.setLeftPaddingPoints(left: 10, right: 10)
        companyTF.setLeftPaddingPoints(left: 10, right: 10)
        educationTF.setLeftPaddingPoints(left: 10, right: 10)
        genderTF.setLeftPaddingPoints(left: 10, right: 10)
        getGender()
        getEducation()
        setTF()
    }
    
    func setTF(){
        self.selectedGender = GenderData(raw: ["id": UserVM.shared.userDict?.genderId ?? 0,
                                               "name" : UserVM.shared.userDict?.genderName ?? ""])
        self.selectedEducation = GenderData(raw: ["id": UserVM.shared.userDict?.educationId ?? 0,
                                               "name" : UserVM.shared.userDict?.educationName ?? ""])
        self.aboutMeTV.text = UserVM.shared.userDict?.aboutMe ?? ""
        self.phoneTF.text = UserVM.shared.userDict?.phoneNumber ?? ""
        self.jobTF.text = UserVM.shared.userDict?.jobTitle ?? ""
        self.companyTF.text = UserVM.shared.userDict?.employer ?? ""
        self.educationTF.text = self.selectedEducation?.name ?? ""
        self.genderTF.text = self.selectedGender?.name ?? ""
        self.ageSlider.value = Float((UserVM.shared.userDict?.age ?? 0) - 18)
        self.ageLabel.text = "\(UserVM.shared.userDict?.age ?? 18)"
        
        self.heightInches = Int(UserVM.shared.userDict?.height ?? 0)
        let cm = 2.54 * Double(heightInches)
        self.heightLabel.text = self.showFootAndInchesFromCm(Double(cm))
        self.heightSlider.value = Float((Double(heightInches - 48)/0.33333) )
        let photos = UserVM.shared.userDict?.photosArray
        if photos?.count == 1{
            self.image1.sd_setImage(with: URL(string: photos?[0]["photoThumbUrl"] as? String ?? ""), for: .normal, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        if photos?.count == 2{
            self.image1.sd_setImage(with: URL(string: photos?[0]["photoThumbUrl"] as? String ?? ""), for: .normal, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
            self.image2.sd_setImage(with: URL(string: photos?[1]["photoThumbUrl"] as? String ?? ""), for: .normal, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        if (photos?.count ?? 0) > 2{
            self.image1.sd_setImage(with: URL(string: photos?[0]["photoThumbUrl"] as? String ?? ""), for: .normal, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
            self.image2.sd_setImage(with: URL(string: photos?[1]["photoThumbUrl"] as? String ?? ""), for: .normal, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
            self.image3.sd_setImage(with: URL(string: photos?[2]["photoThumbUrl"] as? String ?? ""), for: .normal, placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        }
        
        
    }
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        if isSignupFlow{
            if images1 == nil && images2 == nil && images3 == nil{
                self.showAlert(message: "Please add any one image.")
                return
            }
        }
        
        if aboutMeTV.text.count == 0{
            self.showAlert(message: "Please tell us about yourself.")
            return
        }
        if genderTF.isEmpty{
            self.showAlert(message: "Please select gender.")
            return
        }
        if educationTF.isEmpty{
            self.showAlert(message: "Please select education.")
            return
        }
        self.saveProfile()
        return
//        if images1 != nil{
//            let data = self.images1?.jpegData(compressionQuality: 0.5)
//            self.uploadImage(data: data!, imageNo: 1)
//            return
//        }
//        else if images2 != nil{
//            let data = self.images2?.jpegData(compressionQuality: 0.5)
//            self.uploadImage(data: data!, imageNo: 2)
//            return
//        }else if images3 != nil{
//            let data = self.images3?.jpegData(compressionQuality: 0.5)
//            self.uploadImage(data: data!, imageNo: 3)
//            return
//        }else{
//            self.saveProfile()
//        }
        
    }
    
    @IBAction func image3(_ sender: Any) {
        self.selectedImage = 3
        self.imageTapped()
    }
    
    @IBAction func image2(_ sender: Any) {
        self.selectedImage = 2
        self.imageTapped()
    }
    
    @IBAction func image1(_ sender: Any) {
        self.selectedImage = 1
        self.imageTapped()
    }
    
    func showFootAndInchesFromCm(_ cms: Double) -> String {
        
        let feet = cms * 0.0328084
        let feetShow = Int(floor(feet))
        let feetRest: Double = ((feet * 100).truncatingRemainder(dividingBy: 100) / 100)
        let inches = Int(floor(feetRest * 12))
        return "\(feetShow)' \(inches)\""
    }
    
    @IBAction func sliderHeight(_ sender: UISlider) {
        let inches = (sender.value * 0.333333) + 48
        self.heightInches = Int(inches)
        let cm = 2.54 * inches
        self.heightLabel.text = self.showFootAndInchesFromCm(Double(cm))
        
    }
    
    @IBAction func breakButton(_ sender: Any) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "QuestionsVC") as! QuestionsVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    @IBAction func sliderAge(_ sender: UISlider) {
        let age = Int(sender.value) + 18
        self.ageLabel.text = "\(age)"
    }
    //MARK:- Custom Methods
    func imageTapped(){
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
            
        case .denied:
            self.showAlert(message: "Please allow camera permissions.", title: "", otherButtons: nil, cancelTitle: "Open settings".localize()) { (_) in
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                            // Fallback on earlier versions
                        }
                    }
                }
            }
            return
            
        default:
            break
        }
        DispatchQueue.main.async {
            self.imagePicker.delegate = self
            self.showImagePickerController(self.imagePicker, controller: self)
        }
    }
   
    func showImagePickerController(_ imagePicker: UIImagePickerController, controller: UIViewController) {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:"Gallery".localize(), style:UIAlertAction.Style.default, handler: { action in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
//            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
//                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//                controller.present(imagePicker, animated: true, completion: nil)
//            }
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Camera".localize(), style:UIAlertAction.Style.default, handler: { action in
            if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                controller.present(imagePicker, animated: true, completion: nil)
            } else {
                self.showAlert(message: "No camera found".localize())
            }
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localize(), style:UIAlertAction.Style.cancel, handler:nil))
        controller.present(settingsActionSheet, animated:true, completion:nil)
    }

    
    func getGender(){
        
        APIManager1.share.getGender(indicatorReq: true, params: nil) { (data, error, serverError) in
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
            let filteredGenderArray = self.genderArray.filter{$0.id != 5}
            self.genderArray = filteredGenderArray
            self.codePicker.reloadAllComponents()
        }
       
    }
    
    func getEducation(){
        APIManager1.share.getEducation(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.educationArray.removeAll()
            guard let data1 = data as? JSONArray else {
                return
            }
            for data2 in data1{
                self.educationArray.append(GenderData(raw: data2 as NSDictionary))
            }
            self.codePicker.reloadAllComponents()
        }
    }
    
    
   
    func uploadImage(data : Data,imageNo :Int){
        let profileData = data
        let fileUploaded = CLFile(data: profileData, name: "file", fileName: "profilePic.jpg", mimeType: "profilePic/jpg")
        APIManager1.share.uploadImage(imageNo: imageNo,indicatorReq: true, files: fileUploaded, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if imageNo == 1{
                if self.images2 != nil{
                    let data = self.images2?.jpegData(compressionQuality: 0.5)
                    self.uploadImage(data: data!, imageNo: 2)
                    return
                }
                else if self.images3 != nil{
                    let data = self.images3?.jpegData(compressionQuality: 0.5)
                    self.uploadImage(data: data!, imageNo: 3)
                    return
                }else{
                    if self.isSignupFlow{
                        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "QuestionsVC") as! QuestionsVC
                        VC.isSignupFlow = true
                        self.navigationController?.pushViewController(VC, animated: true)
                    }else{
                        self.getUserDetail()
                    }
                }
                
                
            }else if imageNo == 2{
                if self.images3 != nil{
                    let data = self.images3?.jpegData(compressionQuality: 0.5)
                    self.uploadImage(data: data!, imageNo: 3)
                    return
                }
                else{
                    if self.isSignupFlow{
                        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "QuestionsVC") as! QuestionsVC
                        VC.isSignupFlow = true
                        self.navigationController?.pushViewController(VC, animated: true)
                    }else{
                        self.getUserDetail()
                    }
                }
                
            }else if imageNo == 3{
                if self.isSignupFlow{
                    let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "QuestionsVC") as! QuestionsVC
                    VC.isSignupFlow = true
                    self.navigationController?.pushViewController(VC, animated: true)
                }else{
                    self.getUserDetail()
                }
            }else{
                if self.isSignupFlow{
                    let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "QuestionsVC") as! QuestionsVC
                    VC.isSignupFlow = true
                    self.navigationController?.pushViewController(VC, animated: true)
                }else{
                    self.getUserDetail()
                }
            }
            
            
        }
    }
    

    
    func saveProfile(){
        if self.heightInches == 0{
            self.heightInches = 48
        }
        let params = ["aboutMe": self.aboutMeTV.text,
                      "age": Int(self.ageLabel.text ?? "0") ?? 0,
                      "educationId": self.selectedEducation?.id ?? 0,
                      "employer": self.companyTF.text ?? "",
                      "genderId": self.selectedGender?.id ?? 0,
                      "height": self.heightInches,
                      "jobTitle": self.jobTF.text ?? "",
                      "phoneNumber": self.phoneTF.text ?? ""] as [String : Any]
        APIManager1.share.editProfile(indicatorReq: true, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            
            if self.images1 != nil{
                let data = self.images1?.jpegData(compressionQuality: 0.5)
                self.uploadImage(data: data!, imageNo: 1)
                return
            }
            else if self.images2 != nil{
                let data = self.images2?.jpegData(compressionQuality: 0.5)
                self.uploadImage(data: data!, imageNo: 2)
                return
            }else if self.images3 != nil{
                let data = self.images3?.jpegData(compressionQuality: 0.5)
                self.uploadImage(data: data!, imageNo: 3)
                return
            }else{
                if self.isSignupFlow{
                    let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "QuestionsVC") as! QuestionsVC
                    VC.isSignupFlow = true
                    self.navigationController?.pushViewController(VC, animated: true)
                }else{
                    self.getUserDetail()
                }
            }
            
            
            
        }
        
    }
    
    
    
    func getUserDetail(){
        APIManager1.share.getProfile(indicatorReq: true, params: nil) { (data, error, serverError) in
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



extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let cropController = CropViewController(croppingStyle: CropViewCroppingStyle.default, image: pickedImage)
            cropController.aspectRatioPreset = .presetSquare;
            cropController.aspectRatioLockEnabled = true
            cropController.aspectRatioPickerButtonHidden = true
            cropController.delegate = self
            picker.pushViewController(cropController, animated: true)
            

//            let data = pickedImage.jpegData(compressionQuality: 0.5)
//            self.uploadImage(data : data!)
        }
//        dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true)
    }

    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {

        dismiss(animated: true){
            let path = self.directory + "/profileImage.jpg"
            self.profilePath = path
            if self.selectedImage == 1{
                self.image1.setImage(image, for: .normal)
                self.images1 = image
            }
            if self.selectedImage == 2{
                self.image2.setImage(image, for: .normal)
                self.images2 = image
            }
            if self.selectedImage == 3{
                self.image3.setImage(image, for: .normal)
                self.images3 = image
            }
        }

    }
    
}


extension EditProfileVC : UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == educationTF || textField == genderTF{
            addPicker(field: textField)
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == educationTF || textField == genderTF {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == educationTF{
            guard selectedRow < educationArray.count else { return }
            self.educationTF.text = educationArray[selectedRow].name
            self.selectedEducation = educationArray[selectedRow]
        }
        if textField == genderTF{
            guard selectedRow < genderArray.count else { return }
            self.genderTF.text = genderArray[selectedRow].name
            self.selectedGender = genderArray[selectedRow]
        }
        
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
        if pickerView.tag == 2{
            return self.genderArray.count
        }else{
            return self.educationArray.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 2{
            return self.genderArray[row].name
        }else{
            return self.educationArray[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRow = row
    }
}


extension UITextField {
    func setLeftPaddingPoints(left :CGFloat, right : CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
        let paddingView1 = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
        self.rightView = paddingView1
        self.rightViewMode = .always
    }
    
}


