//
//  PayMayaViewController.swift
//  Runner
//
//  Created by Manny Isles on 16/01/2021.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

import UIKit
import PayMayaSDK

class PayMayaViewController: UIViewController {

    var arguments: Dictionary<String, Any>!
    var requestReferenceNumber = "1"
    var items:NSArray!
    var paymentResult: FlutterResult!
    var surveyHash: String!
    var checkOutIdResult: String!
    var urlResult: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 4123450131001381

        // This will create payment token that can be use later
        let createPaymentToken = arguments["createPaymentToken"] != nil

        if (createPaymentToken) {
             PayMayaSDK.presentCardPayment(from: self) { result in

                switch result {
                
                    // Called once the payment token is created
                    case .success(let token):
                        
                        self.saveResult(result: "success:\(token.paymentTokenId)" )

                        // Close the View Controller
                        // self.navigationController?.popViewController(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    // For error handling
                    case .error(let error):
                        self.saveResult(result: "error" )
                        print("Error getting payment token: \(error.localizedDescription)")
                
                }
            }
        }

        let keyExists = arguments["requestReferenceNumber"] != nil
        if (keyExists) {
            
            //requestReferenceNumber = arguments["requestReferenceNumber"] as! String
            // print("requestReferenceNumber: ", arguments["requestReferenceNumber"] as! String)
            self.requestReferenceNumber = arguments["requestReferenceNumber"] as! String
            self.items = arguments["items"] as? NSArray

//            var itemsToBuy = [];
            //for item in self.items {
//                itemsToBuy += CheckoutItem(name: item.name as! String,
//                            quantity: item.quantity as! Int,
//                            totalAmount: CheckoutItemAmount(value: item.value as! Double))
                //print("==item:", item.quantity as! Int)
            //}
        
            // Do any additional setup after loading the view.
             let itemsToBuy = [
                 CheckoutItem(name: arguments["item_name"] as! String,
                             quantity: arguments["item_quantity"] as! Int,
                             totalAmount: CheckoutItemAmount(value: arguments["item_value"] as! Double)),
                 //CheckoutItem(name: "Pants",
                             //quantity: 1,
                             //totalAmount: CheckoutItemAmount(value: 79)),
             ]

            let totalAmount = CheckoutTotalAmount(value: itemsToBuy.map { $0.totalAmount.value }.reduce(0, +), currency: "PHP")

            let redirectUrl = RedirectURL(success: arguments["success"] as! String,
                                        failure: arguments["failure"] as! String,
                                        cancel: arguments["cancel"] as! String)!
                                        
            let checkoutInfo = CheckoutInfo(totalAmount: totalAmount, items: itemsToBuy, redirectUrl: redirectUrl, requestReferenceNumber: arguments["requestReferenceNumber"] as! String)
            
            // let tintColor = UIColor.green
            // let font = UIFont.systemFont(ofSize: 18)
            // let logo = UIImage(named: "myLogo")
            // let buttonStyling = PayButtonStyling(title: "Pay with card", backgroundColor: .blue, textColor: .white)

            PayMayaSDK.presentCheckout(from: self, checkoutInfo: checkoutInfo) { result in
                switch result {
                
                    // Called once the checkout id is created
                    case .prepared(let checkoutId):
                        //self.paymentResult(checkoutId)
                        //self.saveResult(result: checkoutId)
                        self.checkOutIdResult = checkoutId
                    print(checkoutId)
                        
                    // Called once the transaction is finished
                    case .processed(let status):
                        //self.paymentResult(status)
                        //self.saveResult(result: "processed")
                        // The transaction status with your redirection url provided in the CheckoutInfo object
                        switch status {
                            case .success(let url):
                                print(url)
                                self.urlResult = url
                                self.saveResult(result: "success")
                                
                            case .failure(let url):
                                
                                self.urlResult = url
                                self.saveResult(result: "failure")

                                print(url)
                            case .cancel(let url):
                                self.urlResult = url
                                self.saveResult(result: "cancel")
                                print(url)
                        }
                        
                        // Close the View Controller
                        // self.navigationController?.popViewController(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    // Called when user dismisses the checkout controller, passes the last known status.
                    case .interrupted(let status):
                        
                        print("======== Payment Status: ", status!)
                        //print("interrupted")
                        // self.paymentResult("interrupted")
                        
                        self.saveResult(result: "interrupted")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.navigationController?.popToRootViewController(animated: true)
                        }

                        //self.navigationController?.popViewController(animated: true)
                    
                    // For error handling
                    case .error(let error):
                        print(error)
                }
            }
        }
    }

    private func saveResult(result: String!) {

        paymentResult(result + "===" + checkOutIdResult)
        //print("====== Swift Result", result!)
    }

    // private func paymentStatus(status: ) {

    //     paymentResult(result + "===" + checkOutIdResult)
    //     //print("====== Swift Result", result!)
    // }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
