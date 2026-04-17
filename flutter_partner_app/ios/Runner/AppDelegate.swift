import UIKit
import Flutter
import SmartCASDK

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var channelFlutter: FlutterMethodChannel?
    var vnptSmartCASDK: VNPTSmartCASDK?
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let rootView = window?.rootViewController as? FlutterViewController {
            let customParams = CustomParams(
                borderRadiusBtn: 999,
                colorSecondBtn: "#FFFFFF",
                colorPrimaryBtn: "#4788FF",
                featuresLink: "https://www.google.com/?hl=vi",
                logoCustom: "",
                backgroundLogin: ""
            )

            func createConfig(isProd: Bool) -> SDKConfig {
                if isProd {
                    return SDKConfig(
                        clientId: "",
                        clientSecret: "",
                        environment: ENVIRONMENT.PRODUCTION,
                        lang: LANG.VI,
                        isFlutterApp: true,
                        customParams: customParams
                    )
                } else {
                    return SDKConfig(
                        clientId: "",
                        clientSecret: "",
                        environment: ENVIRONMENT.DEMO,
                        lang: LANG.VI,
                        isFlutterApp: true,
                        customParams: customParams
                    )
                }
            }

            func initSDK(isProd: Bool) {
                if( self.vnptSmartCASDK != nil) {
                    self.vnptSmartCASDK?.destroySDK();
                }
                
                let config = createConfig(isProd: isProd)
                self.vnptSmartCASDK = VNPTSmartCASDK(viewController: rootView, config: config)
                GeneratedPluginRegistrant.register(with: self.vnptSmartCASDK?.flutterEngine as! FlutterPluginRegistry);
            }

            initSDK(isProd: false)

            let channel = FlutterMethodChannel(name: "com.vnpt.flutter/partner", binaryMessenger: rootView.binaryMessenger)
            channel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                self.channelFlutter = channel
                if call.method == "switchEnvironment" {
                    guard let envArg = call.arguments as? String else {
                        result(FlutterError(code: "INVALID_ARG", message: "Môi trường không hợp lệ", details: nil))
                        return
                    }
                    let toProd = envArg.uppercased() == "PROD"
                    initSDK(isProd: toProd)
                    result("OK")
                } else if call.method == "getAuthentication" {
                    let customerId = call.arguments as? String ?? ""
                    self.getAuthentication(customerId: customerId)
                } else if call.method == "getMainInfo" {
                    self.getMainInfo()
                } else if call.method == "getWaitingTransaction" {
                    let transactionId = call.arguments as? String ?? ""
                    self.getWaitingTransaction(transactionId: transactionId)
                } 
            })
                
        }
        
        GeneratedPluginRegistrant.register(with: self)
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Lấy thông tin về AccessToken & CredentialId
    func getAuthentication(customerId: String) {
        self.vnptSmartCASDK?.getAuthentication(customerId: customerId, callback: { result in
            self.channelFlutter?.invokeMethod("getAuthenticationResult", arguments: result.toJson())
        });
    }
    
    func getMainInfo() {
        self.vnptSmartCASDK?.getMainInfo(callback: { result in
            self.channelFlutter?.invokeMethod("getMainInfoResult", arguments: result.toJson())
        })
    }
    
    // Khách hàng xác nhận / hủy giao dịch.
    func getWaitingTransaction(transactionId: String) {
        self.vnptSmartCASDK?.getWaitingTransaction(tranId: transactionId, callback: { result in
            self.channelFlutter?.invokeMethod("getWaitingTransactionResult", arguments: result.toJson())
        })
    }
    
    func signOut() {
        self.vnptSmartCASDK?.signOut(callback: { result in
            self.channelFlutter?.invokeMethod("signOutResult", arguments: result.toJson())
        })
    }
    
    func createAccount() {
        self.vnptSmartCASDK?.createAccount(callback: { result in
            self.channelFlutter?.invokeMethod("createAccountResult", arguments: result.toJson())
        })
    }
}
