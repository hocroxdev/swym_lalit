//
//  SwymerDetailVC.swift
//  SYWM
//
//  Created by Maninder Singh on 23/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import SDWebImage

class SwymerDetailVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var keepSwymButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var matchName: UILabel!
    @IBOutlet weak var matchImage: UIImageView!
    
    //MARK:- Variables
    var connectionDetail : UserData?
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.matchName.text = connectionDetail?.firstName ?? ""
        if (self.connectionDetail?.photosArray.count ?? 0) > 0{
            let object = self.connectionDetail?.photosArray[0] as? NSDictionary
            matchImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            matchImage.sd_setImage(with: URL(string: (object?["photoThumbUrl"] as? String ?? "")), placeholderImage: nil, options: [], context: nil)
        }
        
    }
    
    //MARK:- IBActions
    @IBAction func chatButton(_ sender: Any) {
        getChatId(login: "\(connectionDetail?.id ?? 0)")
    }
    
    @IBAction func keepSwymButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func heartButton(_ sender: Any) {
    }
    //MARK:- Custom Methods

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func getChatId(login : String){
        APIManager1.share.getChatId(username: login, indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if let data1 = data as? JSONDictionary{
                let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                VC.chats = UserVM.shared.parseChatList1(data: data1)
                self.navigationController?.pushViewController(VC, animated: true)
            }
            
        }
    }
}
