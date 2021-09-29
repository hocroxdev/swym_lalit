//
//  ChatListVC.swift
//  SYWM
//
//  Created by Maninder Singh on 04/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import SDWebImage

class ChatListVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var collectionVIew: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK:- Variables
    var chats = [Chats]()
    var connections = [ConnectionsReceived]()
    var searched = [Chats]()
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logAnalytics(id: FirebaseEvent.CHAT_CLICKED, parameters: nil)
        searchBar.placeholder = "Search User"
        let whiteImage = UIImage(color: UIColor.white, size: CGSize(width: searchBar.layer.frame.width, height: searchBar.layer.frame.height))
        searchBar.setSearchFieldBackgroundImage(whiteImage, for: .normal)
//        searchBar.setTextField(color: UIColor.white.withAlphaComponent(1))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getConnections()
        self.getList()
    }
    
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Custom Methods
    
    @objc func cellTappedMethod(_ sender:AnyObject){
        let index = sender.view.tag
        getSingleUserProfile(id: searched[index].other.login)
    }
    
    func getConnections(){
        APIManager1.share.connectionReceived(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            let connections = EventVM.shared.parseConnectionsReceive(data: data as! JSONArray)
            self.connections = connections
            self.tableView.reloadData()
            self.collectionVIew.reloadData()
        }
    }
    
    func getList(){
        APIManager1.share.getChatList(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if let data1 = data as? [Chats]{
                self.chats = data1
                self.searched = data1
                self.tableView.reloadData()
            }
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

extension ChatListVC: UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTableViewCell") as! ChatListTableViewCell
        cell.selectionStyle = .none
        let object = self.searched[indexPath.row]
        cell.lastMessage.text = object.lastMessage
        cell.userName.text = object.other.firstName
        cell.userImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.userImage.sd_setImage(with: URL(string: object.other.imageUrl), placeholderImage: nil, options: [], context: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.cellTappedMethod(_:)))

        cell.userImage.isUserInteractionEnabled = true
        cell.userImage.tag = indexPath.row
//        cell.userImage.addGestureRecognizer(tapGestureRecognizer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        VC.chats = self.searched[indexPath.row]
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
}


extension ChatListVC : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.connections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatListCollectionCell", for: indexPath) as! ChatListCollectionCell
        let objeect = self.connections[indexPath.row]
        let image = objeect.fromUser?.photosArray.first?["photoThumbUrl"] as? String ?? ""
        let name = (objeect.fromUser?.firstName ?? "")
            //+ (objeect.fromUser?.lastName ?? "")
        cell.userImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.userImage.sd_setImage(with: URL(string: image), placeholderImage: nil, options: [], completed: nil)
        cell.userName.text = name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SwymerSingleVC") as! SwymerSingleVC
        VC.currentUser =  self.connections[indexPath.row].fromUser
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    
    
}

extension ChatListVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textFieldText: NSString = (searchBar.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: text)
        self.searched = self.chats.filter({ return $0.other.firstName.lowercased().contains(txtAfterUpdate.lowercased())})
        if txtAfterUpdate == ""{
            self.searched = self.chats
        }
        self.tableView.reloadData()
        return true
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.searched = self.chats
        self.tableView.reloadData()
    }
    
}


class ChatListCollectionCell : UICollectionViewCell{
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    
}

class ChatListTableViewCell : UITableViewCell{
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    
    
}


extension UISearchBar {
//    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
//    func setTextField(color: UIColor) {
//        guard let textField = getTextField() else { return }
//        switch searchBarStyle {
//        case .minimal:
//            textField.layer.backgroundColor = color.cgColor
//            textField.layer.cornerRadius = 10
//        case .prominent, .default: textField.backgroundColor = color
//        @unknown default: break
//        }
//    }
}
