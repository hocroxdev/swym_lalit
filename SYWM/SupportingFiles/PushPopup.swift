//
//  PushPopup.swift
//  Trukkin
//
//  Created by Maninder Singh on 09/09/19.
//  Copyright © 2019 Maninder Singh. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

protocol NotificationButtonTappedDelegate {
    func buttonPressed(userInfo :[AnyHashable : Any])
}

class PushPopUp{
    
    
    fileprivate var Title = ""
    fileprivate var message = ""
    
    fileprivate var notificationButton = UIButton()
    fileprivate var appDelegate = AppDelegate()
    var delgate : NotificationButtonTappedDelegate?
    fileprivate var userInfo = [AnyHashable : Any]()
    
    
    init(title : String , message : String,userInfo : [AnyHashable : Any]) {
        self.Title = title
        self.message = message
        self.userInfo = userInfo
        newPopupView()
    }
    
    func newPopupView(){
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.warning)
        view.configureContent(title: self.Title, body: self.message, iconImage: nil, iconText: "", buttonImage: nil, buttonTitle: nil) { (button) in
            print(button)
        }
        view.layoutMarginAdditions = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
//        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 0
        (view.backgroundView as? CornerRoundingView)?.backgroundColor = UIColor.black
        
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 5)
        config.presentationContext = .window(windowLevel: .normal)
        SwiftMessages.show(config: config, view: view)
        view.button?.isHidden = true
        view.tapHandler = { _ in
            self.delgate?.buttonPressed(userInfo: self.userInfo)
            SwiftMessages.hide()
        }
        
    }

    
    @objc func actionNotifcationButtonTapped() {
        self.delgate?.buttonPressed(userInfo: self.userInfo)
    }
    
}
