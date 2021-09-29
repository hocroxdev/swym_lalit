//
//  SwymerVC.swift
//  SYWM
//
//  Created by Maninder Singh on 23/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//
import SDWebImage
import UIKit

class SwymerVC: BaseVC {
    //MARK:- IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var employerLabel: UILabel!
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var hieghtLabel: UILabel!
    @IBOutlet weak var nameAge: UILabel!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noUserView: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userInfoContainer: UIView!
    
    //MARK:- Variables
    var poolId = 0
    var usersInpool = [UserData]()
    var currentUser : UserData?
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getSwymerInPool()
//        getUserInfo()
    }
    
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func crossButton(_ sender: Any) {
        self.crossUser(id: currentUser?.id ?? 0)
    }
    
    @IBAction func heartButton(_ sender: Any) {
        self.loveUser(id: currentUser?.id ?? 0)
    }
    
    @IBAction func undoButton(_ sender: Any) {
        self.undoUser()
    }
    
    
    //MARK:- Custom Methods
    
    func setUseData(user: UserData){
        self.aboutLbl.text = user.aboutMe
        self.employerLabel.text = user.employer
        self.educationLabel.text = user.educationName
        self.genderLabel.text = user.genderName + ", " + "\(user.age)"
//        self.hieghtLabel.text = showFootAndInchesFromCm(user.height)
        let cm = 2.54 * Double(user.height)
        self.hieghtLabel.text = self.showFootAndInchesFromCm(cm)
//        self.hieghtLabel.text = "\(user.height)"
        
        self.nameAge.text = user.firstName
    }

    func showFootAndInchesFromCm(_ cms: Double) -> String {
        
        let feet = cms * 0.0328084
        let feetShow = Int(floor(feet))
        let feetRest: Double = ((feet * 100).truncatingRemainder(dividingBy: 100) / 100)
        let inches = Int(floor(feetRest * 12))
        return "\(feetShow)' \(inches)\""
    }
    
    func getSwymerInPool(){
        APIManager1.share.eventUser(Id: poolId, indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if let users = data as? [JSONDictionary]{
                var usersdetails = [UserData]()
                for user in users{
                    let user = UserData(response: user as NSDictionary)
                    usersdetails.append(user)
                }
                self.usersInpool = usersdetails
                if self.usersInpool.count > 0{
                    self.currentUser = self.usersInpool.first
                    self.setUseData(user: self.usersInpool.first!)
                    self.pageControll.currentPage = 0
                    self.pageControll.numberOfPages = self.currentUser?.photosArray.count ?? 0
                    self.collectionView.reloadData()
                    self.tableView.reloadData()
                    self.noUserView.isHidden = true
                    self.userInfoContainer.isHidden = false
                }else{
                    self.noUserView.isHidden = false
                    self.userInfoContainer.isHidden = true
                }
                
            }
        }
    }

    func getUserInfo(){
        APIManager1.share.getOtherUserProfile(id: 156, indicatorReq: false, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if let users = data as? [JSONDictionary]{
                var usersdetails = [UserData]()
                for user in users{
                    let user = UserData(response: user as NSDictionary)
                    usersdetails.append(user)
                }
                self.usersInpool = usersdetails
                if self.usersInpool.count > 0{
                    self.currentUser = self.usersInpool.first
                    self.setUseData(user: self.usersInpool.first!)
                    self.pageControll.currentPage = 0
                    self.pageControll.numberOfPages = self.currentUser?.photosArray.count ?? 0
                    self.collectionView.reloadData()
                    self.tableView.reloadData()
                    self.noUserView.isHidden = true
                }else{
                    self.noUserView.isHidden = false
                }
                
            }
        }
    }
    
    func loveUser(id : Int){
        let params = ["toUserId" : id,
                      "requestStatus" : "PENDING"] as [String : Any]
        APIManager1.share.loveUser(indicatorReq: true, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.usersInpool.removeAll(where: { $0.id == id})
            if self.usersInpool.count > 0{
                self.currentUser = self.usersInpool.first
                self.setUseData(user: self.usersInpool.first!)
                self.pageControll.currentPage = 0
                self.pageControll.numberOfPages = self.currentUser?.photosArray.count ?? 0
                self.collectionView.reloadData()
                self.tableView.reloadData()
                self.noUserView.isHidden = true
            }else{
                self.noUserView.isHidden = false
            }
        }
    }
    
    func crossUser(id : Int){
        let params = ["toUserId" : id,
                      "requestStatus" : "CANCEL"] as [String : Any]
        APIManager1.share.crossuser(indicatorReq: true, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.usersInpool.removeAll(where: { $0.id == id})
            if self.usersInpool.count > 0{
                self.currentUser = self.usersInpool.first
                self.setUseData(user: self.usersInpool.first!)
                self.pageControll.currentPage = 0
                self.pageControll.numberOfPages = self.currentUser?.photosArray.count ?? 0
                self.collectionView.reloadData()
                self.tableView.reloadData()
                self.noUserView.isHidden = true
            }else{
                self.noUserView.isHidden = false
            }
        }
    }
    
    func undoUser(){
        APIManager1.share.recoverUser(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.getSwymerInPool()
        }
    }
}


extension SwymerVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentUser?.photosArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwymImageCell", for: indexPath) as! SwymImageCell
        let object = self.currentUser?.photosArray[indexPath.item] as? NSDictionary
        cell.swymImage.sd_imageIndicator = SDWebImageActivityIndicator.gray

        cell.swymImage.sd_setImage(with: URL(string: (object?["photoThumbUrl"] as? String ?? "")), placeholderImage: nil, options: [], context: nil)
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        pageControll.currentPage = indexPath.item
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = self.currentUser?.photosArray[indexPath.item] as? NSDictionary
        
    }
    
}

extension SwymerVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentUser?.questions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionsBTICell") as! QuestionsBTICell
        cell.selectionStyle = .none
        let object = self.currentUser?.questions[indexPath.row]
        if let question = object?["question"] as? NSDictionary{
            print(question)
            let question = question["name"] as? String ?? ""
            cell.questionLabel.text = question
        }
        let answer = object?["answer"] as? String ?? ""
        cell.anserLabrl.text = answer
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (tableView.indexPathsForVisibleRows!.last! as! NSIndexPath).row {
            let contentSize : CGSize = self.tableView.contentSize
            let width = self.tableView.contentSize.width
            let height = self.tableView.contentSize.height
            self.tableViewHeight.constant = height
        }
    }
   
    
}

class SwymImageCell : UICollectionViewCell{
    
    @IBOutlet weak var swymImage: UIImageView!
    
}

class QuestionsBTICell : UITableViewCell{
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var anserLabrl: UILabel!
    
}
