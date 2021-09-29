//
//  NetworkInterface.swift
//  FriendsApp
//
//  Created by Maninder Singh on 21/10/17.
//  Copyright © 2017 ManinderBindra. All rights reserved.
//
import Foundation
import Alamofire
import NVActivityIndicatorView
//import Lottie

//MARK: Call Backs
typealias JSONDictionary = [String:Any]
typealias JSONArray = [JSONDictionary]
typealias APIServiceSuccessCallback = ((Any?,Data?) -> ())
typealias APIServiceFailureCallback = ((NetworkErrorReason?, NSError?) -> ())
typealias JSONArrayResponseCallback = ((JSONArray?, Data?) -> ())
typealias JSONDictionaryResponseCallback = ((JSONDictionary?, Data?) -> ())
typealias responseCallBack = ((Bool, String?, NSError?) -> ())


//MARK: Constant

public enum NetworkErrorReason: Error {
    case FailureErrorCode(code: Int, message: String)
    case InternetNotReachable
    case UnAuthorizedAccess
    case Other
}

struct Resource {
    let method: HTTPMethod
    let parameters: [String : Any]?
    let headers: [String:String]?
}

protocol APIService {
    var path: String { get }
    var resource: Resource { get }
}

extension APIService {
    
    /**
     Method which needs to be called from the respective model class.
     - parameter successCallback:   successCallback with the JSON response.
     - parameter failureCallback:   failureCallback with ErrorReason, Error description and Error.
     */
    
    //MARK: Request Method to Send Request except in Multipart
    func request(isURLEncoded: Bool = false, success: @escaping APIServiceSuccessCallback, failure: @escaping APIServiceFailureCallback) {
        do {
            if Indicator.isEnabledIndicator {
                Indicator.sharedInstance.showIndicator()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            debugPrint("********************************* API Request **************************************")
            debugPrint("Request URL:\(path)")
            debugPrint("Request resource: \(resource)")
            debugPrint("************************************************************************************")
            
            var encoding: JSONEncoding = .default
            if resource.method == .get || resource.method == .head || resource.method == .delete || isURLEncoded{
                encoding = .prettyPrinted
            }
            
            debugPrint("Request method: \(resource.method)")
            debugPrint("Request parameter:\(String(describing: resource.parameters))")
            debugPrint("Request encoding: \(encoding)")
            debugPrint("Request headers: \(String(describing: resource.headers))")
            
            Alamofire.request(path, method: resource.method, parameters: resource.parameters, encoding: encoding, headers: resource.headers).validate(statusCode: 200..<300).validate(contentType: ["application/json", "application/xml"]).responseJSON(completionHandler: { (response) in
                debugPrint("********************************* API Response *************************************")
                debugPrint("\(response.debugDescription)")
                debugPrint("************************************************************************************")
                if Indicator.isEnabledIndicator {
                    Indicator.sharedInstance.hideIndicator()
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                switch response.result {
                case .success(let value):
                    success(value as AnyObject?, response.data)
                    
                case .failure(let error):
                    if let data = response.data, data.count > 0 {
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String : Any]{
                                let code = jsonArray["status"] as? Int ?? 0
                                let error  = NSError(domain: error.localizedDescription, code: code, userInfo: jsonArray)
                                self.handleError(response: response, error: error, callback: failure)
                            } else {
                                print("bad json")
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    }else{
                        self.handleError(response: response, error: error as NSError, callback: failure)
                    }
                }
            })
        }
    }
    
    
    
    //MARK: Request Method to Upload Multipart
    func uploadMultiple(imageDict:[String: Data]?,success:  @escaping APIServiceSuccessCallback, failure: @escaping APIServiceFailureCallback) {
        do {
            debugPrint("********************************* API Request **************************************")
            debugPrint("Request URL:\(path)")
            debugPrint("Request resource: \(resource)")
            debugPrint("image dictionary: \(String(describing: imageDict))")
            
            
            debugPrint("************************************************************************************")
            if Indicator.isEnabledIndicator {
                Indicator.sharedInstance.showIndicator()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let urlRequest = createRequestWithMultipleImages(urlString: path, parameters: resource.parameters, imageDict: imageDict)
            Alamofire.upload((urlRequest?.1)!, with: (urlRequest?.0)!).uploadProgress(closure: { (progress) in
                print(progress.localizedDescription)
            }).responseJSON(completionHandler: { (response) in
                debugPrint("********************************* API Response *************************************")
                debugPrint("\(response.debugDescription)")
                debugPrint("************************************************************************************")
                if Indicator.isEnabledIndicator {
                    Indicator.sharedInstance.hideIndicator()
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                switch response.result {
                case .success(let value):
                    success(value as AnyObject?, response.data)
                case .failure(let error):
                    self.handleError(response: response, error: error as NSError, callback: failure)
                }
            })
        }
    }
    
    func createRequestWithMultipleImages(urlString:String, parameters:[String : Any]?, imageDict: [String: Data]?) -> (URLRequestConvertible, Data)? {
        
        // create url request to send
        var mutableURLRequest = URLRequest(url: NSURL(string: urlString)! as URL)
        mutableURLRequest.httpMethod = resource.method.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        var uploadData = Data()
        if parameters != nil {
            for (key, value) in parameters! {
                uploadData.append("--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
                uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                uploadData.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        if imageDict != nil {
            for (key, value) in imageDict! {
                uploadData.append("--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
                uploadData.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).png\"\r\n".data(using: String.Encoding.utf8)!)
                uploadData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
                uploadData.append(value)
                uploadData.append("\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        uploadData.append("--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        do {
            let result = try Alamofire.URLEncoding.default.encode(mutableURLRequest, with: nil)
            return (result, uploadData)
        }
        catch _ {
        }
        
        return nil
    }
    
    //MARK: Data Handling
    // Convert from NSData to json object
    private func JSONFromData(data: NSData) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers)
        } catch let myJSONError {
            debugPrint(myJSONError)
        }
        return nil
    }
    
    // Convert from JSON to nsdata
    private func nsdataFromJSON(json: AnyObject) -> NSData?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData?
        } catch let myJSONError {
            debugPrint(myJSONError)
        }
        return nil;
    }
    
    //MARK: Error Handling
    private func handleError(response: DataResponse<Any>?, error: NSError, callback:APIServiceFailureCallback) {
        Indicator.sharedInstance.hideIndicator()
        Indicator.isEnabledIndicator = true
        if let errorCode = response?.response?.statusCode {
            guard let responseJSON = self.JSONFromData(data: (response?.data)! as NSData) else {
                callback(NetworkErrorReason.FailureErrorCode(code: errorCode, message:""), error)
                debugPrint("Couldn't read the data")
                return
            }
            let message = (responseJSON as? NSDictionary)?["err"] as? String ?? "Something went wrong. Please try again.".localize()
            callback(NetworkErrorReason.FailureErrorCode(code: errorCode, message: message), error)
        }
        else {
            let customError = NSError(domain: "Network Error".localize(), code: error.code, userInfo: error.userInfo)
            if let errorCode = response?.result.error?.localizedDescription , errorCode == "The Internet connection appears to be offline.".localize() {
                callback(NetworkErrorReason.InternetNotReachable, customError)
            }
            else {
                callback(NetworkErrorReason.Other, customError)
            }
        }
    }
    
    func showAlert(message: String?, title:String = "Trukkin".localize(), otherButtons:[String:((UIAlertAction)-> ())]? = nil, cancelTitle: String = "Ok".localize(), cancelAction: ((UIAlertAction)-> ())? = nil) {
        let newTitle = title.capitalized
        let newMessage = message
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction))
        
        if otherButtons != nil {
            for key in otherButtons!.keys {
                alert.addAction(UIAlertAction(title: key, style: .default, handler: otherButtons![key]))
            }
        }
        let d = UIApplication.shared.delegate as! AppDelegate
        d.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: API Manager Class
class APIManager {
    class func errorForNetworkErrorReason(errorReason: NetworkErrorReason) -> NSError {
        var error: NSError!
        
        switch errorReason {
        case .InternetNotReachable:
            error = NSError(domain: "No Internet".localize(), code: -1, userInfo: [kMessage : "The Internet connection appears to be offline.".localize()])
        case .UnAuthorizedAccess:
            error = NSError(domain: "Authorization Failed".localize(), code: 0, userInfo: [kMessage : "Please Re-login to the app.".localize()])
        case let .FailureErrorCode(code, message):
            switch code {
            case 500:
                error = NSError(domain: "Server Error".localize(), code: code, userInfo: [kMessage : message])
            default:
                error = NSError(domain: "Please try again.".localize(), code: code, userInfo: [kMessage : message])
            }
            
        case .Other:
            error = NSError(domain: "Please try again.".localize(), code: 0, userInfo: [kMessage : "Something went wrong!".localize()])
        }
        return error
    }
}

//MARK: Indicator Class
public class Indicator {
    
    public static let sharedInstance = Indicator()
    var blurImg = UIImageView()
    var indicator = UIActivityIndicatorView()
    static var isEnabledIndicator = true
    let activityData = ActivityData()
    
    private init() {
        blurImg.frame = UIScreen.main.bounds
        blurImg.backgroundColor = UIColor.black
        blurImg.isUserInteractionEnabled = true
        blurImg.alpha = 0.5
        indicator.style = .whiteLarge
        indicator.center = blurImg.center
        indicator.startAnimating()
        indicator.color = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
    }
    
    func showIndicator(){
        DispatchQueue.main.async( execute: {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(self.activityData, nil)
//            UIApplication.shared.keyWindow?.addSubview(self.blurImg)
//            UIApplication.shared.keyWindow?.addSubview(self.indicator)
        })
    }
    func hideIndicator(){
        DispatchQueue.main.async( execute: {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
//            self.blurImg.removeFromSuperview()
//            self.indicator.removeFromSuperview()
        })
    }
    
    
}


