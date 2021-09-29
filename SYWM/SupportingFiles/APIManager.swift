

import Foundation
protocol APIManagerRoules {
    var requestHeaders: [String: String]? {get}
}

final class APIManager1: APIManagerRoules {
    
    final var requestHeaders: [String: String]? {
        var headers = ["content-language": "en"]
        if let token = DataManager.accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        print(headers)
        return headers
    }
    
    static let share = APIManager1()
    typealias APIManagerCallBack = ((_ response: Any?, _ error: Error? , _ serverError: Any?) -> Void)
    
    func getJoinOrLeaveEvent(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .put, path: "api/event-users", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func registerDevice(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/device", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? [String: Any] {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func getProfile(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/user-profiles/me", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    UserVM.shared.userDict = UserData(response: jsonObject as NSDictionary)
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func socailogin(loginType : String,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/login/\(loginType)", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    DataManager.accessToken = jsonObject["id_token"] as? String ?? ""
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func appleLogin(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        HTTPRequest(method: .post, path: "api/login/APPLE", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    DataManager.accessToken = jsonObject["id_token"] as? String ?? ""
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    
    func getCheckActivePool(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/event-users/active/me", parameters: params, encoding: EncodingType.url, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func getEvents(lat : Double,long: Double,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/events/\(lat)/\(long)", parameters: params, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func breakTheIceQuestions(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/user-questions", parameters: params, encoding: EncodingType.url, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func breakTheIceAnswer(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .put, path: "api/user-questions", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func editProfile(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .put, path: "api/user-profiles", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func getOtherUserProfile(id : Int,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        ///api/user-connects/done/{id}
        HTTPRequest(method: .get, path: "api/user-connects/done/\(id)", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func getOtherUserProfile1(id : String,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/user-profiles/login/\(id)", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func getChatId(username : String,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/chats/user/\(username)", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
        }
    }
    
    func getEducation(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/educations", parameters: params, encoding: EncodingType.url, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func getGender(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/genders", parameters: params, encoding: EncodingType.url, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func getFAQ(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/faq", parameters: params, encoding: EncodingType.url, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func deleteAccount(Id : Int,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .delete, path: "api/users/me", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func getSettings(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/user-settings/me", parameters: params, encoding: EncodingType.url, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func updateSettings(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .put, path: "api/user-settings", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func askFAQ(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/faq/ask", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func processPayment(indicatorReq: Bool = false, nonce : String , callBack: @escaping APIManagerCallBack) {
        let params = ["nonce": nonce]
        HTTPRequest(method: .post, path: "api/payment/square/create-event", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    
    func getLevels(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/sponsor-level/all", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func createEvent(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/events", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
                
        }
    }
    
    func uploadImage(imageNo : Int, indicatorReq: Bool,files: CLFile,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/photos/upload/\(imageNo)", parameters: params, encoding: EncodingType.json, files: [files]).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .multipartHandler(httpModel: false) { (object: Any?, error: Error?,serverError: Any?)  in
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? [String: Any]{
                    callBack(jsonObject, nil, nil)
                }
        }
    }
    
    
    func eventUser(Id : Int,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/event-users/event/\(Id)", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    callBack(jsonObject, nil, nil)
                }
        }
    }
    
    func crossuser(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/user-connects", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
        }
    }
    
    
    func crossuser1(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .put, path: "api/user-connects", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
        }
    }
    
    func recoverUser(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/user-connects/recover", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
        }
    }
    
    
    func loveUser(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/user-connects", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
        }
    }
    
    func loveUser1(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .put, path: "api/user-connects", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
        }
    }
    
    func connectionReceived(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/user-connects/received", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: true)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    callBack(jsonObject, nil, nil)
                }
        }
    }
    
    
    func getChatList(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/chats/me", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    let data = UserVM.shared.parseChatList(response: jsonObject)
                    callBack(data, nil, nil)
                }
                
        }
    }
   
    func singleConnection(id : Int ,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        HTTPRequest(method: .get, path: "api/user-connects/received/\(id)", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func sendMessages(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/chat-messages", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func getChatMessages(chatId: Int,lastMessageId: Int,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .get, path: "api/chat-messages/\(chatId)/\(lastMessageId)", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONArray {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func reportUser(indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/report-users", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func blockUser(chatId : String,indicatorReq: Bool,params : [String: Any]? , callBack: @escaping APIManagerCallBack) {
        
        HTTPRequest(method: .post, path: "api/chats/\(chatId)/end", parameters: params, encoding: EncodingType.json, files: nil).config(isIndicatorEnable: indicatorReq, isAlertEnable: false)
            .handler(httpModel: false, delay: 0.0) { (object: Any?, error: Error?, serverError: Any?) in
                
                if error != nil || serverError != nil {
                    self.logoutIfRequired(serverError: serverError)
                    callBack(nil, error, serverError)
                    return
                }
                if let jsonObject = object as? JSONDictionary {
                    callBack(jsonObject, nil, nil)
                }
                
        }
    }
    
    func logoutIfRequired(serverError: Any?){
        if serverError != nil{
            if let server = serverError as? NSDictionary{
                let status = server["status"] as? Int ?? 0
                if status == 403 {
                    NotificationCenter.default.post(name: .logout, object: nil)
                }
            }
        }
    }
    
    
    
    
}
extension String {
    func blank(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    var trimText:String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    
    
    var length: Int {
        return self.count
    }
}

import Foundation

extension Notification.Name {
    static let logout = Notification.Name("logout")

}

