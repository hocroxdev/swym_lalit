//
//  PaymentInfoViewController.swift
//  SYWM
//
//  Created by Arun J on 19/08/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit

class PaymentInfoViewController: UIViewController {
    enum PaymentMode {
        case card
        case applePay
        case cancel
    }
    internal var paymentSelectedListner: PaymentSelectedListner?
    typealias PaymentSelectedListner = ( _ mode: PaymentMode) -> ()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func payWithCardClicked(_ sender: Any) {
        paymentSelectedListner?(.card)
    }
    @IBAction func applePayClicked(_ sender: Any) {
        paymentSelectedListner?(.applePay)
    }
    
    @IBAction func onCloseClicked(_ sender: Any) {
        paymentSelectedListner?(.cancel)
    }
    func onPaymentSelected( listner: @escaping PaymentSelectedListner) {
        self.paymentSelectedListner = listner
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
