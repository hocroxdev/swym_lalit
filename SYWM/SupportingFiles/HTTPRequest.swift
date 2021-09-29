

import UIKit
import Alamofire

struct HTTPDefalut {
    static var unauthorized: Int = 401 //
}

// MARK: - File
struct CLFile: CustomStringConvertible {
    
    private(set) var name: String?
    private(set) var fileName: String?
    private(set) var mimeType: String?
    private(set) var data: Data?
    private(set) var url: URL?
    private(set) var type: AppendType?
    
    enum AppendType: Int {
        case type1
        case type2
        case type3
    }
    
    init(data: Data, name: String, fileName: String, mimeType: String) {
        self.type = .type1
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        self.data = data
    }
    
    init(url: URL, name: String, fileName: String, mimeType: String) {
        self.type = .type2
        self.url = url
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    init(url: URL, name: String) {
        self.type = .type3
        self.url = url
        self.name = name
    }
    
    func apendFile(mulitpartData: MultipartFormData) {
        
        if let type = type {
            
            switch type {
            case .type1:
                
                if let data = self.data, let name = self.name, let fileName = self.fileName, let mimeType = self.mimeType {
                    mulitpartData.append(data, withName: name, fileName: fileName, mimeType: mimeType)
                }
                break
            case .type2:
                if let url = self.url, let name = self.name, let fileName = self.fileName, let mimeType = self.mimeType {
                    mulitpartData.append(url, withName: name, fileName: fileName, mimeType: mimeType)
                }
                break
            case .type3:
                if let url = self.url, let name = self.name {
                    mulitpartData.append(url, withName: name)
                }
                break
            }
            
        }
        
    }
    
    var description: String {
        return "Name: \(name) fileName: \(fileName) mimeType: \(mimeType) data: \(data)"
    }
    
}

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

struct HTTPModel: CustomStringConvertible {
    
    var statusCode: Int = -1
    let data: Any?
    var message: String = "Unknown message".localize()
    
    var description: String {
        return "Data: {statusCode: \(statusCode) message: \(message), data: \(String(describing: data)) }"
    }
    
    init?(response: HTTPURLResponse, representation: Any) {
        let representation = representation as? [String: Any]
        guard
            let message = representation?["message"],
            let status = representation?["status"]
            else { return nil }
        
        let data = representation?["data"]
        if let code = status as? Int {
            self.statusCode = code
        }
        
        self.data = data
        if let msg = message as? String {
            self.message = msg
        }
        
    }
}

enum EncodingType {
    case json
    case url
    case propertyType
    func value() -> ParameterEncoding {
        switch self {
        case .json:
            return JSONEncoding.default
        case .url:
            return URLEncoding.default
        case .propertyType:
            return PropertyListEncoding.default
        }
    }
}

public typealias HTTPRequestHandler = (_ response: Any?, Error? , Any?) -> Void
public typealias HTTPTimelineHandler = (_ timeline: Timeline) -> Void

// MARK: -
extension Notification.Name {
    /// These notifications are sent out after the equivalent delegate message is called
    public struct HTTPRequestStatus {
        /// These notification will fire when access token expired or not valid.
        public static let unauthorized = Notification.Name(rawValue: "clicklabs.HTTPRequest.unauthorized")
        public static let locationName = Notification.Name(rawValue: "locationName")
    }
    
}

class HTTPRequest {
    
    public typealias HTTPEncodingCompletionHandler = (_ request: HTTPRequest) -> Void
    
    //Public
    class var baseURLString: String {
        return BASE_API_URL
        
    }
    
    private var baseURL: URL?
    private var urlString: String?
    
    class var baseUrl: URL {
        if let url = URL(string: HTTPRequest.baseURLString) {
            return url
        }
        fatalError("HTTPRequest:- Base url issue")
    }
    
    private var methodType: Alamofire.HTTPMethod
    private var parameters: Parameters?
    private var encoding: ParameterEncoding
    private var headers = [String: String]()
    private var files: [CLFile]?
    private var isIndicatorEnable = true
    private var isAlertEnable = true
    
    private(set) var timeline: Timeline?
    
    private var dataRequest: DataRequest?
    //private var uploadRequest: UploadRequest? = nil
    //private var downloadRequest: DownloadRequest? = nil
    
    //CallBack
    private var completeCallBack: HTTPRequestHandler?
    private var progressCallBack: HTTPRequestHandler?
    private var timelineCallBack: HTTPTimelineHandler?
    private var encodingCompletion: HTTPEncodingCompletionHandler?
    var networkManager: NetworkReachabilityManager?
    
    // MARK: - END
    // MARK: - init
    init() {
        self.methodType = .get
        self.encoding = URLEncoding.default
        self.urlString = HTTPRequest.baseURLString
        
        if let defaultHeaders: [String : String] = APIManager1.share.requestHeaders {
            self.headers.appendDictionary(other: defaultHeaders)
        }
        
        //----
        //        if let defaultHeaders: [String : String] = LoginManager.share.requestHeaders {
        //            self.headers.appendDictionary(other: defaultHeaders)
        //        }
        
    }
    
    @discardableResult
    convenience init(method: Alamofire.HTTPMethod = .get,
                     fullURLStr: String,
                     parameters: Parameters? = nil,
                     encoding: EncodingType = .url,
                     files: [CLFile]? = nil) {
        self.init()
        self.urlString = fullURLStr
        self.methodType = method
        self.parameters = parameters
        self.files = files
        self.encoding = encoding.value()
    }
    
    convenience init(method: Alamofire.HTTPMethod = .get,
                     path: String,
                     parameters: Parameters? = nil,
                     encoding: EncodingType = .url,
                     files: [CLFile]? = nil) {
        self.init(method: method,
                  fullURLStr: "\(HTTPRequest.baseURLString)\(path)",
            parameters: parameters,
            encoding: encoding,
            files: files)
    }
    
    class func request(method: Alamofire.HTTPMethod = .get,
                       path: String,
                       parameters: Parameters? = nil,
                       encoding: EncodingType = .url,
                       files: [CLFile]? = nil) -> HTTPRequest {
        return HTTPRequest(method: method, path: path, parameters: parameters, encoding: encoding, files: files)
    }
    
    // MARK: - Public Methods.
    @discardableResult
    func uploadEncodingCompletion(encodingCompletion: @escaping HTTPEncodingCompletionHandler) -> HTTPRequest {
        self.encodingCompletion = encodingCompletion
        return self
    }
    
    @discardableResult
    func headers(headers: [String: String]) -> HTTPRequest {
        self.headers.appendDictionary(other: headers)
        return self
    }
    
    @discardableResult
    func config(isIndicatorEnable: Bool, isAlertEnable: Bool) -> HTTPRequest {
        self.isIndicatorEnable = isIndicatorEnable
        self.isAlertEnable = isAlertEnable
        return self
    }
    
    @discardableResult
    func encodingType(encoding: EncodingType) -> HTTPRequest {
        self.encoding = encoding.value()
        return self
    }
    
    @discardableResult
    func requestTimeline(_ timeline: @escaping HTTPTimelineHandler) -> HTTPRequest {
        self.timelineCallBack = timeline
        return self
    }
    
    // MARK: - Handler...
    func handler(httpModel: Bool = false, delay: TimeInterval = 0.0, completion: @escaping HTTPRequestHandler) {
        self.completeCallBack = completion
        if delay > 0 {
            DispatchQueue.performAction(after: delay, callBack: { (isSuccess: Bool) -> (Void) in
                self.startRequest(httpModelOn: httpModel)
            })
        } else {
            self.startRequest(httpModelOn: httpModel)
        }
    }
    
    func multipartHandler(httpModel: Bool = false, delay: TimeInterval = 0.0, completion: @escaping HTTPRequestHandler) {
        self.completeCallBack = completion
        if delay > 0 {
            DispatchQueue.performAction(after: delay, callBack: { (isSuccess: Bool) -> (Void) in
                self.upload(httpModelOn: httpModel)
            })
        } else {
            self.upload(httpModelOn: httpModel)
        }
    }
    
    // MARK: -
    // MARK: - Private Methods
    // MARK: -
    private func authorized(code: Int, message: String) -> Bool {
        if code == HTTPDefalut.unauthorized {
            UIAlertController.presentAlert(title: "", message: message, style: UIAlertController.Style.alert).action(title: "Ok".localize(), style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
                
                NotificationCenter.default.post(name: Notification.Name.HTTPRequestStatus.unauthorized, object: nil)
            })
            return false
        }
        return true
    }
    
    private func showAlertMessage(message: String) {
        if self.isAlertEnable == false {
            return
        }
        UIAlertController.presentAlert(title: "", message: message, style: UIAlertController.Style.alert).action(title: "Ok".localize(), style: UIAlertAction.Style.default) { (action: UIAlertAction) in
        }
    }
    
    private func showIndicator() {
        if self.isIndicatorEnable == false {
            return
        }
        ActivityIndicator.shared.startAnimatingIndicator()
        //  CLProgressHUD.present(animated: true)
    }
    
    private func hideIndicator() {
        ActivityIndicator.shared.stopAnimatingIndicator()
        //  CLProgressHUD.dismiss(animated: true)
    }
    
    private func upload(httpModelOn: Bool) {
        
        guard let urlString = self.urlString else {
            fatalError("HTTPRequest:- URL string is not exist")
        }
        
        self.showIndicator()
        
        Alamofire.upload( multipartFormData: { [weak self] multipartFormData in
            
            //Append files
            if let files = self?.files {
                for file in files {
                    file.apendFile(mulitpartData: multipartFormData)
                }
            }
            
            //Append files
            if let parameters = self?.parameters {
                for (key, value) in parameters {
                    if value is [String : Any] || value is [Any] {
                        do {
                            
                            let data  = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted )
                            if  let jsonString: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue), let data = jsonString.data(using: String.Encoding.utf8.rawValue) {
                                multipartFormData.append(data, withName: key)
                            }
                            
                        } catch {
                            print ("Error in parsing" )
                        }
                    } else {
                        if let data = "\(value)".data(using: String.Encoding.utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                }
            }
            },
                          to: urlString,
                          method: self.methodType,
                          headers: self.headers,
                          encodingCompletion: { encodingResult in
                            
                            if let encodingCompletion = self.encodingCompletion {
                                encodingCompletion(self)
                            }
                            
                            switch encodingResult {
                                
                            case .success(let upload, _, _):
                                
                                self.dataRequest = upload
                                
                                if httpModelOn == true {
                                    fatalError("HTTPModel is not availabel")
                                } else {
                                    upload.responseJSON { response in
                                        self.requestSucceededWith(response: response)
                                    }
                                }
                                
                            case .failure(let encodingError):
                                
                                self.requestFailedWith(error: encodingError)
                            }
                            
        })
    }
    
    //Start request...
    private func startRequest(httpModelOn: Bool) {
        
        guard let urlString = self.urlString else {
            fatalError("HTTPRequest:- URL string is not exist")
        }
        
        self.showIndicator()
        print("URL--->",self.urlString ?? "")
        print("Params--->",self.parameters ?? "")
        let dataRequest = Alamofire.request(urlString,
                                            method: self.methodType,
                                            parameters: self.parameters,
                                            encoding: self.encoding,
                                            headers: self.headers)
        debugPrint("Request parameter:\(String(describing: self.parameters))")
        debugPrint("Request encoding: \(encoding)")
        debugPrint("Request headers: \(String(describing: self.headers))")
        self.dataRequest = dataRequest
        if httpModelOn == true {
            fatalError("HTTPModel is not availabel")
        } else {
            
            if let dataRequest = self.dataRequest {
                dataRequest.responseJSON(completionHandler: { (response: DataResponse<Any>) in
                    
                    //self.timeline = response.timeline
                    self.timeline = response.timeline
                    if let timeLine = self.timeline {
                        if let timelineCallBack = self.timelineCallBack {
                            timelineCallBack(timeLine)
                        }
                    }
                    
                    switch response.result {
                        
                    case .success(_):
                        print(response)
                        self.requestSucceededWith(response: response)
                        
                    case .failure(let error):
                        self.requestFailedWith(error: error)
                        
                    }
                })
                
            }
            
        }
        
    }
    
    private func requestSucceededWith(response: DataResponse<Any>) {
        //TODO: After Success simple request.
        self.hideIndicator()
        
        var statusCode = 0
        
        let responseObject = response.result.value
        let dict = responseObject as? [String : Any]
        
        //getting status code from server response
        if let tempStatusCode = dict?["statusCode"] as? Int {
            statusCode = tempStatusCode
        } else if let tempStatusCode = response.response?.statusCode {
            statusCode = tempStatusCode
        }
        
        switch statusCode {
        case 200..<300:
            self.completeCallBack?(responseObject, nil, nil)
            
        case 300..<500:
            self.completeCallBack?(nil, nil, responseObject)
        default:
            let message = (dict?["message"] as? String) ?? "Something went wrong. Please try again in some time.".localize()
            let error = self.errorWithDescription(description: message, code: statusCode)
            requestFailedWith(error: error)
        }
    }
    
    private func requestFailedWith(error: Error) {
        
        self.hideIndicator()
        
        let message: String = error.localizedDescription
        
        guard self.authorized(code: (error as NSError).code, message: message) else {
            self.completeCallBack?(nil, error, nil)
            return
        }
        
        showAlertMessage(message: message)
        self.completeCallBack?(nil, error, nil)
        
    }
    
    private func errorWithDescription(description: String, code: Int) -> Error {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: "app", code: code, userInfo: userInfo) as Error
    }
    
}

class ActivityIndicator {
    
    // MARK: - Shared Instance
    static let shared = ActivityIndicator()
    
    // MARK: - Properties
    let loadingContainerView = UIView()
    let loadingIndicatorView = UIView()
    let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Methods
    func startAnimatingIndicator() {
        if let navigationController = ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? UINavigationController) { //activity indicator view will be added in this view
            var viewController = UIViewController()
            if let topVC = navigationController.topViewController{
                viewController = topVC
            }
            if let presentedVC = navigationController.presentedViewController{
                viewController = presentedVC
            }
            
            viewController.view.isUserInteractionEnabled = false
            loadingContainerView.frame = viewController.view.frame
            loadingContainerView.center = CGPoint(x: ScreenConstant.width/2, y: ScreenConstant.height/2)
            loadingContainerView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.2)
            loadingIndicatorView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
            loadingIndicatorView.center = loadingContainerView.center
            loadingIndicatorView.backgroundColor = UIColor.init(red: 0/255, green: 0/2555, blue: 0/255, alpha: 0.65)
            loadingIndicatorView.clipsToBounds = true
            loadingIndicatorView.layer.cornerRadius = 7
            loadingContainerView.layer.masksToBounds = true
            activityIndicator.frame = CGRect(x: 17.5, y: 17.5, width: 35.0, height: 35.0)
            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            loadingIndicatorView.addSubview(activityIndicator)
            loadingContainerView.addSubview(loadingIndicatorView)
            viewController.view.addSubview(loadingContainerView)
            activityIndicator.startAnimating()
        }
    }
    func stopAnimatingIndicator() {
        if let navigationController = ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? UINavigationController) { //activity indicator view will be added in this view
            var viewController1 = UIViewController()
            var viewController2 = UIViewController()
            if let topVC = navigationController.topViewController{
                viewController1 = topVC
            }
            if let presentedVC = navigationController.presentedViewController{
                viewController2 = presentedVC
            }
            viewController1.view.isUserInteractionEnabled = true
            viewController2.view.isUserInteractionEnabled = true
            activityIndicator.stopAnimating()
            loadingContainerView.removeFromSuperview()
        }
    }
}
func generateTag(section: Int, row: Int) -> Int {
    let tag = (1000 * (section + 1)) + (row + 1)
    return tag
}
var rootViewController: UIViewController {
    get {
        return (UIApplication.shared.keyWindow?.rootViewController)!
    }
    set {
        UIApplication.shared.keyWindow?.rootViewController = newValue
    }
}
struct ScreenConstant {
    static var width = UIScreen.main.bounds.size.width
    static var height = UIScreen.main.bounds.size.height
    static var originX = UIScreen.main.bounds.origin.x
    static var originY = UIScreen.main.bounds.origin.y
}
public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
    
    private class func delay(delay: TimeInterval, closure: @escaping () -> Void) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    class func performAction(after seconds: TimeInterval, callBack: @escaping ((Bool) -> Void) ) {
        DispatchQueue.delay(delay: seconds) {
            callBack(true)
        }
    }
    
}
extension Dictionary {
    
    //Append Dictionary
    mutating func appendDictionary(other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
    static func += <K, V> ( left: inout [K:V], right: [K:V]) {
        for (k, v) in right {
            left.updateValue(v, forKey: k)
        }
    }
}

extension UIAlertController {
    
    typealias AlertAction = (UIAlertAction) -> Void
    
    func present() {
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }
    
    @discardableResult
    func action(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let action: UIAlertAction = UIAlertAction(title: title, style: style, handler: handler)
        self.addAction(action)
        return self
    }
    
    @discardableResult
    class func alert(title: String?, message: String?, style: UIAlertController.Style) -> UIAlertController {
        let alertController: UIAlertController  = UIAlertController(title: title, message: message, preferredStyle: style)
        return alertController
    }
    
    //@discardableResult
    class func presentAlert(title: String?, message: String?, style: UIAlertController.Style) -> UIAlertController {
        let alertController = UIAlertController.alert(title: title, message: message, style: style)
        alertController.present()
        return alertController
    }
    
    class func showAlertWithMultipleButtons(_ buttonTitles: [String], viewController: UIViewController?, message: String?, title: String?, completion: [AlertAction?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, buttonTitle) in buttonTitles.enumerated() {
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: completion[index])
            alert.addAction(action)
        }
        if let vc = viewController {
            vc.present(alert, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    class func showAlertMessage(_ buttonTitle: String, viewController: UIViewController?, message: String?, title: String?, completion: AlertAction?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: buttonTitle, style: .default, handler: completion)
        alert.addAction(dismissAction)
        if let vc = viewController {
            vc.present(alert, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlert(message: String?, title:String = "", otherButtons:[String:((UIAlertAction)-> ())]? = nil, cancelTitle: String = "Ok".localize(), cancelAction: ((UIAlertAction)-> ())? = nil) {
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
}

