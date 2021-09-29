//
//  LaunchPoolVC.swift
//  SYWM
//
//  Created by Maninder Singh on 05/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import NVActivityIndicatorView
import SquareInAppPaymentsSDK

enum Result<T> {
    case success
    case failure(T)
    case canceled
}

class LaunchPoolVC: BaseVC {

   
    //MARK:- IBOutlets
    
    @IBOutlet weak var isEventButton: UIButton!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var sponserNameView: UIView!
    @IBOutlet weak var sponserName: UITextField!
    @IBOutlet weak var sponserCode: UITextField!
    @IBOutlet weak var sponserLevel: UITextField!
    @IBOutlet weak var eventname: UITextField!
    @IBOutlet weak var eventTV: UITextView!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    
    //MARK:- Variables
    fileprivate var applePayResult: Result<String> = Result.canceled
    var startDatePickerView = UIDatePicker()
    var endDatePickerView = UIDatePicker()
    var selectedRow = 0
    var sponserArray = ["Gold","Platinum","Silver"]
    let activityData = ActivityData()
    var codePicker = UIPickerView()
    var createEventParams = CreateEventParams()
    var startDate1 = Date()
    var endDate1 = Date()
    private var serverHostSet: Bool {
        return BASE_API_URL != "REPLACE_ME"
    }
    
    private var appleMerchanIdSet: Bool {
        return ApplePay.MERCHANT_IDENTIFIER != "REPLACE_ME"
    }
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getLevel()
    }
    
    //MARK:- IBActions
    @IBAction func isEventButton(_ sender: Any) {
        self.isEventButton.isSelected = !self.isEventButton.isSelected
        if self.isEventButton.isSelected{
            self.codeView.isHidden = false
            self.levelView.isHidden = false
            self.sponserNameView.isHidden = false
            self.createEventParams.sponsor = true
        }else{
            self.codeView.isHidden = true
            self.levelView.isHidden = true
            self.sponserNameView.isHidden = true
            self.createEventParams.sponsor = false
        }
    }
    
    @IBAction func submitButton(_ sender: Any) {
        if self.createEventParams.sponsor{
            if self.sponserName.isEmpty{
                self.showAlert(message: "Please enter sponsor name.")
                return
            }
            if self.sponserCode.isEmpty{
                self.showAlert(message: "Please enter sponsor code.")
                return
            }
            if self.sponserLevel.isEmpty{
                self.showAlert(message: "Please enter sponsor level.")
                return
            }
        }
        if self.eventname.isEmpty{
            self.showAlert(message: "Please enter event name.")
            return
        }
        if self.eventTV.text.count == 0{
            self.showAlert(message: "Please enter event descirption.")
            return
        }
        if self.startDate.isEmpty{
            self.showAlert(message: "Please enter event start date.")
            return
        }
        if self.endDate.isEmpty{
            self.showAlert(message: "Please enter event end date.")
            return
        }

        if self.startDate1 > endDate1{
            self.showAlert(message: "Start date should be less then end date.")
            return
        }

        if self.locationTF.isEmpty{
            self.showAlert(message: "Please choose locaitons.")
            return
        }
        
        if self.createEventParams.sponsor{
            
            let message = "Sponsored pools are not currently available through the app reach out to info@swymapp.com for any inquiries"
            let subject = "Create sponsored pools"
            self.showMailAlert(message: message, subject: subject)
            return
        }
        let differenceInSeconds = self.startDate1.timeIntervalSince(self.endDate1)
        if differenceInSeconds.magnitude > 86405{
            let message = "SWYM’ing pools have a 24 hour maximum. If you would like to schedule a longer event or have custom requirements reach out to us at info@swymapp.com."
            let subject = "Create Event longer than 24 hours"
            self.showMailAlert(message: message, subject: subject)
            return
           
        }

        if self.createEventParams.sponsor{
            self.callCreateEventApi()
        }else{
            self.showPaymentPopUp()
        }
        
//
    }
    
        func showMailAlert(message:String,subject:String){
            self.showAlert(message: message, title: "", otherButtons: ["Contact": {_ in
                    self.sendEmail(email:"info@swymapp.com", subject:subject)
            
                }], cancelTitle: "OK", cancelAction: nil)
        }
        
    func callCreateEventApi(){
        let params = ["name": eventname.text ?? "",
                      "latitude": self.createEventParams.lat,
                      "longitude": self.createEventParams.long,
                      "city": self.createEventParams.city,
                      "state": self.createEventParams.state,
                      "country": self.createEventParams.country,
                      "location": self.createEventParams.location,
                      "descrip": self.eventTV.text ?? "",
                      "startDate": self.createEventParams.startDate,
                      "endDate": self.createEventParams.endDate,
                      "sponsored": self.createEventParams.sponsor,
                      "sponsorName" : self.sponserName.text ?? "",
                      "sponsorCode" : self.sponserCode.text ?? "",
                      "levelOfSponsor" : self.createEventParams.levelOfSponsor] as [String : Any]
        self.createEvent(params: params)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Custom Methods

    @objc func handleStartDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MMM dd yyyy HH:mm a"
        startDate.text = dateFormatter.string(from: sender.date)
        self.startDate1 = sender.date
    }
    
    @objc func handleEndDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        dateFormatter.dateFormat = "MMM dd yyyy HH:mm a"
        endDate.text = dateFormatter.string(from: sender.date)
        self.endDate1 = sender.date
    }
    
    func showPaymentPopUp(){
        let storyboard = UIStoryboard(name: "Events", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "kPaymentInfoViewController") as! PaymentInfoViewController
        vc.onPaymentSelected { paymentMode in
            if paymentMode == .applePay {
                self.dismiss(animated: true) {
                    self.requestApplePayAuthorization()
                }
//                self.requestApplePayAuthorization()
            }else if paymentMode == .cancel {
                self.dismiss(animated: true) {}
            }else{
                self.initiatePayWithCard()
            }
        }
        let nc = OrderNavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = self
        present(nc, animated: true, completion: nil)
    }
    
    func initiatePayWithCard() {
        dismiss(animated: true) {
            let vc = self.makeCardEntryViewController()
            
            vc.delegate = self

            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true, completion: nil)
        }
    }
}
extension LaunchPoolVC {
    func makeCardEntryViewController() -> SQIPCardEntryViewController {
        // Customize the card payment form
        let theme = SQIPTheme()
        theme.errorColor = .red
        theme.tintColor = Color.primaryAction
        theme.keyboardAppearance = .light
        theme.messageColor = Color.descriptionFont
        theme.saveButtonTitle = "Pay"

        return SQIPCardEntryViewController(theme: theme)
    }
    private func didNotChargeApplePay(_ error: String) {
        // Let user know that the charge was not successful
        let alert = UIAlertController(title: "Your order was not successful",
                                      message: error,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func didChargeSuccessfully() {
        // Let user know that the charge was successful
        let alert = UIAlertController(title: "Your order was successful",
                                      message: "Go to your Square dashbord to see this order reflected in the sales tab.",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showCurlInformation() {
        let alert = UIAlertController(title: "Nonce generated but not charged",
                                      message: "Check your console for a CURL command to charge the nonce, or replace Constants.Square.CHARGE_SERVER_HOST with your server host.",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showMerchantIdNotSet() {
        let alert = UIAlertController(title: "Missing Apple Pay Merchant ID",
                                      message: "Missing Apple Pay Merchant ID",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    private func printCurlCommand(nonce : String) {
        let uuid = UUID().uuidString
        print("curl --request POST https://connect.squareup.com/v2/payments \\" +
            "--header \"Content-Type: application/json\" \\" +
            "--header \"Authorization: Bearer YOUR_ACCESS_TOKEN\" \\" +
            "--header \"Accept: application/json\" \\" +
            "--data \'{" +
            "\"idempotency_key\": \"\(uuid)\"," +
            "\"autocomplete\": true," +
            "\"amount_money\": {" +
            "\"amount\": 100," +
            "\"currency\": \"USD\"}," +
            "\"source_id\": \"\(nonce)\"" +
            "}\'");
    }
}
extension LaunchPoolVC: SQIPCardEntryViewControllerDelegate {
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {
        // Note: If you pushed the card entry form onto an existing navigation controller,
        // use UINavigationController.popViewController(animated:) instead
        dismiss(animated: true) {
            switch status {
            case .canceled:
                self.showPaymentPopUp()
                break
            case .success:
                self.callCreateEventApi()
//                guard self.serverHostSet else {
//                    self.showCurlInformation()
//                    return
//                }
//
//                self.didChargeSuccessfully()
            }
        }
    }

    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didObtain cardDetails: SQIPCardDetails, completionHandler: @escaping (Error?) -> Void) {
        guard serverHostSet else {
            printCurlCommand(nonce: cardDetails.nonce)
            completionHandler(nil)
            return
        }
        
        APIManager1.share.processPayment(nonce: cardDetails.nonce) { data, error, serverError in
            if error != nil{
                let error = NSError(domain: "com.swym", code: 0, userInfo:[NSLocalizedDescriptionKey : "Something went wrong"])
                completionHandler(error)
                return
            }
            if serverError != nil{
                let error = NSError(domain: "com.swym", code: 0, userInfo:[NSLocalizedDescriptionKey : "Something went wrong"])
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }

//        ChargeApi.processPayment(cardDetails.nonce) { (transactionID, errorDescription) in
//            guard let errorDescription = errorDescription else {
//                // No error occured, we successfully charged
//                completionHandler(nil)
//                return
//            }
//
//            // Pass error description
//            let error = NSError(domain: "com.swym", code: 0, userInfo:[NSLocalizedDescriptionKey : errorDescription])
//            completionHandler(error)
//        }
    }
}
extension LaunchPoolVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//extension LaunchPoolVC: HalfSheetPresentationControllerHeightProtocol {
//    var halfsheetHeight: CGFloat {
//        return 400
//    }
//}
extension LaunchPoolVC : UITextFieldDelegate,UITextViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == sponserLevel{
            addPicker(field: textField)
        }
        if textField == startDate{
            startDatePickerView.minimumDate = Date()
            startDatePickerView.locale = Locale(identifier: "en")
            startDatePickerView.datePickerMode = .dateAndTime
            startDatePickerView.addTarget(self, action: #selector(handleStartDatePicker(sender:)), for: .valueChanged)
            startDate.inputView = startDatePickerView
            self.startDate1 = Date()
        }
        if textField == endDate{
            endDatePickerView.minimumDate = Date()
            endDatePickerView.locale = Locale(identifier: "en")
            endDatePickerView.datePickerMode = .dateAndTime
            endDatePickerView.addTarget(self, action: #selector(handleEndDatePicker(sender:)), for: .valueChanged)
            endDate.inputView = endDatePickerView
            self.endDate1 = Date()
        }
        if textField == locationTF{
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            self.present(autocompleteController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == sponserLevel{
            return false
        }
        if textField == startDate{
            return false
        }
        if textField == endDate{
            return false
        }
        if textField == locationTF{
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == sponserName{
            sponserCode.becomeFirstResponder()
        }
        if textField == sponserCode{
            sponserLevel.becomeFirstResponder()
        }
        if textField == sponserLevel{
            eventname.becomeFirstResponder()
        }
        if textField == eventname{
            eventTV.becomeFirstResponder()
        }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        if textField == startDate{
            dateFormatter.dateFormat = "MMM dd yyyy HH:mm a"
            startDate.text = dateFormatter.string(from: startDatePickerView.date)
            self.createEventParams.startDate = startDatePickerView.date.timeIntervalSince1970
            self.startDate1 = startDatePickerView.date
        }
        if textField == endDate{
            dateFormatter.dateFormat = "MMM dd yyyy HH:mm a"
            endDate.text = dateFormatter.string(from: endDatePickerView.date)
            self.endDate1 = endDatePickerView.date
            self.createEventParams.endDate = endDatePickerView.date.timeIntervalSince1970
        }
        if textField == sponserLevel{
            self.sponserLevel.text = sponserArray[selectedRow]
            self.createEventParams.levelOfSponsor = self.sponserArray[selectedRow]
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.sponserArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sponserArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRow = row
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
}

extension LaunchPoolVC: GMSAutocompleteViewControllerDelegate {
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        locationTF.text = place.formattedAddress != nil ? place.formattedAddress : ""
        self.createEventParams.lat = place.coordinate.latitude
        self.createEventParams.long = place.coordinate.longitude
        self.createEventParams.location = place.formattedAddress ?? ""
        
        var city = ""
        var state = ""
        var country = ""
        var ad1 = ""
        var ad2 = ""
        if let addressess = place.addressComponents{
            for component in addressess {
                if component.types.contains("locality") {
                    print("City : " + component.name)
                    city = component.name
                }
                if component.types.contains("country") {
                    print("country : " + component.name)
                    country = component.name
                }
                if component.types.contains("sublocality_level_1") {
                    print("location1 : " + component.name)
                }
                
                if component.types.contains("sublocality_level_2") {
                    print("location2 : " + component.name)
                }
                if component.types.contains("administrative_area_level_1") {
                    print("State : " + component.name)
                    ad1 = component.name
                }
                if component.types.contains("administrative_area_level_2") {
                    print("State : " + component.name)
                    ad2 = component.name
                }
            }
        }
        if state != ""{
            state = ad1
        }
        if ad2 != ""{
            state = ad2
        }
        if country == ""{
            country = city
        }
        if city == ""{
            city = country
        }
        if city == "" && country == ""{
            city = place.formattedAddress ?? ""
            country = place.formattedAddress ?? ""
        }
        
        self.createEventParams.city = city
        self.createEventParams.state = state
        self.createEventParams.country = country
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension LaunchPoolVC{
    
    func getLevel(){
        APIManager1.share.getLevels(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if let resposneArray = data as? JSONArray{
                self.sponserArray.removeAll()
                for data in resposneArray{
                    self.sponserArray.append(data["level"] as? String ?? "")
                }
                self.codePicker.reloadAllComponents()
            }
        }
    }
    
    func createEvent(params : [String: Any]){
        APIManager1.share.createEvent(indicatorReq: true, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.logAnalytics(id: FirebaseEvent.POOL_CREATED, parameters: nil)
            var message = "Event created successfully."
            if self.createEventParams.sponsor{
                
                message = "Sponsored pools are not currently available through the app reach out to info@swymapp.com for any inquiries"
            }
            self.showAlert(message: message, title: "", otherButtons: nil, cancelTitle: "OK", cancelAction: { (_) in
                 self.navigationController?.popViewController(animated: true)
            })
            
        }
    }
}

extension LaunchPoolVC: PKPaymentAuthorizationViewControllerDelegate {
    func requestApplePayAuthorization() {
        
        guard SQIPInAppPaymentsSDK.canUseApplePay else {
            return
        }

        guard appleMerchanIdSet else {
            showMerchantIdNotSet()
            return
        }

        let paymentRequest = PKPaymentRequest.squarePaymentRequest(
            merchantIdentifier: ApplePay.MERCHANT_IDENTIFIER,
            countryCode: ApplePay.COUNTRY_CODE,
            currencyCode: ApplePay.CURRENCY_CODE
        )

        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Payment for SWYM pool event", amount: 6.99)
        ]

        let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)

        paymentAuthorizationViewController!.delegate = self

        present(paymentAuthorizationViewController!, animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            handler completion: @escaping (PKPaymentAuthorizationResult) -> Void){

        // Turn the response into a nonce, if possible
        // Nonce is used to actually charge the card on the server-side
        let nonceRequest = SQIPApplePayNonceRequest(payment: payment)

        nonceRequest.perform { [weak self] cardDetails, error in
            guard let cardDetails = cardDetails else {
                let errors = [error].compactMap { $0 }
                completion(PKPaymentAuthorizationResult(status: .failure, errors: errors))
                return
            }
            
            guard let strongSelf = self else {
                completion(PKPaymentAuthorizationResult(status: .failure, errors: []))
                return
            }
            
            guard strongSelf.serverHostSet else {
                strongSelf.printCurlCommand(nonce: cardDetails.nonce)
                strongSelf.applePayResult = .success
                completion(PKPaymentAuthorizationResult(status: .failure, errors: []))
                return
            }
            
            ChargeApi.processPayment(cardDetails.nonce) { (transactionId, error) in
                if let error = error, !error.isEmpty {
                    strongSelf.applePayResult = Result.failure(error)
                } else {
                    strongSelf.applePayResult = Result.success
                }

                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            }
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            switch self.applePayResult {
            case .success:
                guard self.serverHostSet else {
                    self.showCurlInformation()
                    return
                }
//                self.didChargeSuccessfully()
                 self.callCreateEventApi()
            case .failure(let description):
                self.didNotChargeApplePay(description)
                break
            case .canceled:
                self.showPaymentPopUp()
            }
        }
    }
}

class CreateEventParams{
    
    var lat = 0.0
    var long = 0.0
    var city = ""
    var state = ""
    var country = ""
    var location = ""
    var name = ""
    var desc = ""
    var startDate : Double = 0
    var endDate : Double = 0
    var sponsor = false
    var sponsorName = ""
    var sponsorCode = ""
    var levelOfSponsor = ""
    
}
