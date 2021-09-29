//
//  WebVC.swift
//  SYWM
//
//  Created by Maninder Singh on 16/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import WebKit

class WebVC: BaseVC , WKNavigationDelegate{
    //MARK:- IBOutlets
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //MARK:- Variables
    
    var header = ""
    var link = ""
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerLabel.text = self.header
        self.webView.navigationDelegate = self
        self.webView.load(URLRequest(url: URL(string: link)!))
    }
    
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Custom Methods

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicatorView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
       activityIndicatorView.isHidden = true
    }
    
    

}
