import UIKit
import Flutter
import PayMayaSDK // added
import GoogleMaps // added

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    // Added
    var navigationController: UINavigationController!
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Add for firebase message
    if #available(iOS 10.0, *) {
    //   UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      // Replace Sept 26, 2021. Original is above
      UNUserNotificationCenter.current().delegate = self
    }
    // added from here
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    linkNativeCode(controller: controller)

    PayMayaSDK.setup(environment: .sandbox, logLevel: .all, authenticationKeys: [
        .checkout: "pk-NCLk7JeDbX1m22ZRMDYO9bEPowNWT5J4aNIKIbcTy2a",
        .payments: "pk-NCLk7JeDbX1m22ZRMDYO9bEPowNWT5J4aNIKIbcTy2a",
        .cardToken: "pk-NCLk7JeDbX1m22ZRMDYO9bEPowNWT5J4aNIKIbcTy2a"
    ])

    // added end
    
    // added for google maps
    // GMSServices.provideAPIKey("AIzaSyBvYIn85W4Z7AW2QyUsDLB81v0RNufoHC8")
    GMSServices.provideAPIKey("AIzaSyCCgaVlDWys8gyYOxfTJUwpM3zIoMQfQ24")
    // end google maps

    // Dont move this as is
    GeneratedPluginRegistrant.register(with: self)
    
    // added
    self.navigationController = UINavigationController(rootViewController: controller)
    self.window.rootViewController = self.navigationController
    self.navigationController.setNavigationBarHidden(true, animated: false)
    self.window.makeKeyAndVisible()
    // added end
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
}

extension AppDelegate {
    
    func linkNativeCode(controller: FlutterViewController) {
        setupMethodChannelForPayMaya(controller: controller)
    }
    
    private func setupMethodChannelForPayMaya(controller: FlutterViewController) {
        
        let payMayaChannel = FlutterMethodChannel.init(name: "paymaya.flutter.dev", binaryMessenger: controller.binaryMessenger)
        
        payMayaChannel.setMethodCallHandler { (call, result) in
            if call.method == "payViaPayMaya" {
                
                // https://prnt.sc/wshvbw
                // For reference
                let vc = UIStoryboard.init(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "PayMaya") as! PayMayaViewController
                
                    // For arguments or parameters
    //             if let arguments = call.arguments as? String {
    //                 vc.surveyHash = arguments
    //             }
                //vc.surveyResult = result
                // if let arguments = call.arguments as? Dictionary<String, Any> {
                //     vc.arguments = arguments
                // }
                if let arguments = call.arguments as? Dictionary<String, Any> {
                    vc.arguments = arguments
                }
                vc.paymentResult = result //  Asign result from paymaya
                //print("======== Result Status: ", result)
                //self.getResult(result: result)
                self.navigationController.pushViewController(vc, animated: true)
            }

            // if call.method == "createPaymentToken" {
                
            //     let vc = UIStoryboard.init(name: "Main", bundle: nil)
            //         .instantiateViewController(withIdentifier: "PayMaya") as! PayMayaViewController
               
            //     if let arguments = call.arguments as? Dictionary<String, Any> {
            //         vc.arguments = arguments
            //     }
            //     vc.paymentResult = result //  Asign result from paymaya
            // }

            if call.method == "videoCallVonage" {
                
                let vc2 = UIStoryboard.init(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "Vonage") as! VonageViewController
                
                if let arguments = call.arguments as? Dictionary<String, Any> {
                    vc2.arguments = arguments
                }
                vc2.videoResult = result
                self.navigationController.pushViewController(vc2, animated: true)
            }
        }
    }
    
    private func getResult(result: String!) {
      
        //result("====== Swift Result", result)
      
    }
}

