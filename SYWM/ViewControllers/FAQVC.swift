//
//  FAQVC.swift
//  SYWM
//
//  Created by Maninder Singh on 05/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class FAQVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Variables
    var faqData = [FAQData]()
    var activityData = ActivityData()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getFAQs()
    }
    
    //MARK:- IBActions
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Custom Methods
    func getFAQs(){
        APIManager1.share.getFAQ(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.faqData.removeAll()
            guard let data1 = data as? JSONArray else {
                return
            }
            for data2 in data1{
                self.faqData.append(FAQData(raw: data2 as NSDictionary))
            }
            self.tableView.reloadData()
        }
        
    }

}

extension FAQVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.faqData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell") as! FAQCell
        cell.selectionStyle = .none
        cell.questionLabel.text = faqData[indexPath.row].question
        cell.answerLabel.text = faqData[indexPath.row].answer
        return cell
    }
    
    
    
}

class FAQCell : UITableViewCell{
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
}
