//
//  ChatVC.swift
//  Iclean
//
//  Created by Mac on 20/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import GrowingTextView
import IQKeyboardManagerSwift
import SDWebImage

class ChatVC: BaseVC {
    //MARK:- IBOutlets
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var growingTV: GrowingTextView!
    @IBOutlet weak var inpusViewHeight: NSLayoutConstraint!
    
    //MARK:- Variables
    var fromListVC = false
    var chats = Chats()
    var chatMessages = [ChatMessage]()
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logAnalytics(id: FirebaseEvent.SINGLE_CHAT, parameters: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateMessage(_:)), name: NSNotification.Name(rawValue: "NEWMESSAGE"), object: nil)
        self.userImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.userImage.sd_setImage(with: URL(string: chats.other.imageUrl), placeholderImage: nil, options: [], context: nil)
        self.userNameLabel.text = chats.other.firstName
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.cellTappedMethod(_:)))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(tapGestureRecognizer)
        getMessages()
    }
    
    @objc func updateMessage(_ sender : NSNotification){
        let object = sender.object as! ChatMessage
        chatMessages.append(object)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: chatMessages.count-1, section: 0)], with: .automatic)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: IndexPath(row: chatMessages.count-1, section: 0), at: .bottom, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        textView.textContainerInset = UIEdgeInsets.zero
//        textView.textContainer.lineFragmentPadding = 0
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self)
        self.logAnalytics(id: FirebaseEvent.END_CHAT, parameters: nil)
    }
    
    //MARK:- IBActions
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reportButton(_ sender: Any) {
        self.showImagePickerController(controller: self)
    }
    
    @IBAction func sendButton(_ sender: Any) {
        if growingTV.text.count == 0{
            return
        }
        sendMessage()
    }
    
    @objc func cellTappedMethod(_ sender:AnyObject){
        getSingleUserProfile(id: chats.other.login)
    }
    
    //MARK:- Custom Methods
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //key point 0,
                self.inpusViewHeight.constant =  0
                //textViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
            }
        }
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                self.inpusViewHeight.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    if self.chatMessages.count > 2{
                        self.tableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: .bottom, animated: false)
                    }
                })
            }
        }
    }
    
    
    func showImagePickerController(controller: UIViewController) {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:"Report User", style:UIAlertAction.Style.default, handler: { action in
            
            self.showAlert(message: "Are you sure you want report this user?", title: "", otherButtons: ["Yes" :{ _ in
                    self.reportUser()
                }], cancelTitle: "No", cancelAction: { (_) in
                    
            })
            
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"End Chat", style:UIAlertAction.Style.default, handler: { action in
            self.showAlert(message: "Are you sure you want end this chat?", title: "", otherButtons: ["No" :{ _ in
                
                }], cancelTitle: "Yes", cancelAction: { (_) in
                    self.blockuser()
            })
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localize(), style:UIAlertAction.Style.cancel, handler:nil))
        controller.present(settingsActionSheet, animated:true, completion:nil)
    }

    
    func getMessages(){
        APIManager1.share.getChatMessages(chatId: chats.id, lastMessageId: 0, indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if let data1 = data as? JSONArray{
                self.chatMessages = UserVM.shared.parseChatMessage(response: data1)
                self.tableView.reloadData()
            }
            if self.chatMessages.count > 2{
                self.tableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: .bottom, animated: false)
            }
            
        }
    }
    
    
    func reportUser(){
        let params = ["login" : chats.other.id,
                      "reason" : "nothing"] as [String : Any]
        APIManager1.share.reportUser(indicatorReq: true, params: params) { (data, error, serverError) in
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
    
    func blockuser(){
        APIManager1.share.blockUser(chatId: "\(self.chats.id)", indicatorReq: true, params: nil) { (data, error, serverError) in
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
    
    func sendMessage(){
        let params = ["chatId": chats.id,
                      "message":self.growingTV.text ?? ""] as [String : Any]
        APIManager1.share.sendMessages(indicatorReq: false, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.growingTV.text = ""
            let chatMessage = UserVM.shared.parseChatSingleMessage(data: data as! JSONDictionary)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NEWMESSAGE"), object: chatMessage)
        }
    }
    
    func getSingleUserProfile(id : String){
        APIManager1.share.getOtherUserProfile1(id: id, indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                return
            }
            if let detail = data as? NSDictionary{
                let user =  UserData(response: detail)
                let VC = UIStoryboard.init(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SwymerSingleVC") as! SwymerSingleVC
                VC.currentUser = user
                VC.showOnlyDetail = true
                self.navigationController?.pushViewController(VC, animated: true)
            }
           
        }
    }
}


extension ChatVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.chatMessages[indexPath.row]
        if object.sender.login == UserVM.shared.userDict?.login{
            let myCell = tableView.dequeueReusableCell(withIdentifier: "MyChatCell") as! MyChatCell
            myCell.selectionStyle = .none
            myCell.dateLabel.text = object.sentOn.UTCToLocal(incomingFormat: "yyyy-MM-dd\'T\'HH:mm:ssZ", outGoingFormat: "hh:mm a")
            myCell.messageLabel.text = object.message
            return myCell
        }else{
            let otherCell = tableView.dequeueReusableCell(withIdentifier: "OtherChatCell") as! OtherChatCell
            otherCell.messageLabel.text = object.message
            otherCell.dateLabel.text = object.sentOn.UTCToLocal(incomingFormat: "yyyy-MM-dd\'T\'HH:mm:ssZ", outGoingFormat: "hh:mm a")
            return otherCell
        }
    }
}


class MyChatCell : UITableViewCell{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
}

class OtherChatCell : UITableViewCell{
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
}


extension ChatVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func timeAgoSinceDate(_ dateInt:Int, numericDates:Bool = false) -> String {
        if dateInt == 0 {return ""}
        let dateInSeconds = Double(dateInt / 1000)
        let date = Date(timeIntervalSince1970: dateInSeconds)
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
}
