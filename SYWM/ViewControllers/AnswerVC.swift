//
//  AnswerVC.swift
//  SYWM
//
//  Created by Maninder Singh on 04/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import GrowingTextView
class AnswerVC: BaseVC {

    //MARK:- IBOutlets
    @IBOutlet weak var detailTV: GrowingTextView!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    //MARK:- Variables
    var questions : BreakIceData?
    var activityData = ActivityData()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionLabel.text = questions?.question ?? ""
        self.detailTV.text = questions?.answer ?? ""
    }
    
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        if self.detailTV.text.count == 0{
            return
        }
        self.putAnswer()
    }
    
    //MARK:- Custom Methods
    func putAnswer(){
        let params = ["answer":self.detailTV.text,
                      "id":self.questions?.id ?? 0,
                      "questionId":self.questions?.questionId ?? 0] as [String : Any]
        APIManager1.share.breakTheIceAnswer(indicatorReq: true, params: params) { (data, error, serverError) in
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
