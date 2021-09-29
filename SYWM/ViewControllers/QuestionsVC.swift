//
//  QuestionsVC.swift
//  SYWM
//
//  Created by Maninder Singh on 04/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class QuestionsVC: BaseVC {

    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    //MARK:- Variables
    var questions = [BreakIceData]()
    var activityData = ActivityData()
    var isSignupFlow = false
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if isSignupFlow{
            self.submitButton.isHidden = false
        }else{
            self.submitButton.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getQuestions()
    }
    
    //MARK:- IBActions
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    //MARK:- Custom Methods
    func getQuestions(){
        
        APIManager1.share.breakTheIceQuestions(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.questions.removeAll()
            guard let data1 = data as? JSONArray else {
                return
            }
            for data2 in data1{
                self.questions.append(BreakIceData(raw: data2 as NSDictionary))
            }
            self.tableView.reloadData()
        }
        
    }

}

extension QuestionsVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreakCell") as! BreakCell
        cell.selectionStyle = .none
        cell.questionLabel.text = self.questions[indexPath.row].question
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "AnswerVC") as! AnswerVC
        VC.questions = self.questions[indexPath.row]
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
}




class BreakCell : UITableViewCell{
    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
}
