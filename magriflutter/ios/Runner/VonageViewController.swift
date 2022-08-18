//
//  PayMayaViewController.swift
//  Runner
//
//  Created by Manny Isles on 16/01/2021.
//  Copyright © 2021 The Chromium Authors. All rights reserved.
//

import UIKit
// import OpenTok

// *** Fill the following variables using your own Project info  ***
// ***            https://tokbox.com/account/#/                  ***
// Replace with your OpenTok API key
let kApiKey = ""
// Replace with your generated session ID
let kSessionId = ""
// Replace with your generated token
let kToken = ""

let kWidgetHeight = 240
let kWidgetWidth = 320

class VonageViewController: UIViewController {

    var arguments: Dictionary<String, Any>!
    var videoResult: FlutterResult!
    var checkOutIdResult: String!
    var urlResult: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoResult("vonage")
    }

    private func saveResult(result: String!) {

        //paymentResult(result + "===" + checkOutIdResult)
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
