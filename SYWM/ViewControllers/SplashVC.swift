//
//  SplashVC.swift
//  SYWM
//
//  Created by Mac on 15/07/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {
    
    //MARK:- IBOutlets
    
    
    //MARK:- Variables
    
    
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as! AppDelegate).setRootVC()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            (UIApplication.shared.delegate as! AppDelegate).setRootVC()
//        }
    }
    
    
    //MARK:- IBActions
    
    
    //MARK:- Custom Methods
    
}
