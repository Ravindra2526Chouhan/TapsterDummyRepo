//
//  AppDelegate.swift
//  TapsterWhiteLabel
//
//  Created by mac on 11/10/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit
import Mixpanel
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
      
        User.currentUser.initWithInfo(isAPICall: false)
      
        // Override point for customization after application launch.

        ReadSettingJson()
        UIApplication.shared.statusBarStyle = .lightContent        
        return true
    }

    func ReadSettingJson() {
      //read setting json file
      if let path = Bundle.main.path(forResource: "settings", ofType: "json") {
        do {
          let jsonData = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
          do {
            let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            User.currentUser.appName = jsonResult.value(forKey: "appName") as! String
            User.currentUser.vendorGroupId = jsonResult.value(forKey: "vendorGroupId") as! String
            User.currentUser.merchantId = jsonResult.value(forKey: "merchantId") as! String
            User.currentUser.appColor = jsonResult.value(forKey: "appColor") as! String
            User.currentUser.appLogo = jsonResult.value(forKey: "logoImage") as! String
            
            User.currentUser.stripeTestKey = jsonResult.value(forKey: "stripeTestKey") as! String
            User.currentUser.stripePublishKey = jsonResult.value(forKey: "stripePublishKey") as! String
            User.currentUser.splashScreen = jsonResult.value(forKey: "splashScreen") as! String
            User.currentUser.bundleId = jsonResult.value(forKey: "bundleId") as! String
            User.currentUser.applyMerchantIdDev = jsonResult.value(forKey: "applyMerchantIdDev") as! String
            User.currentUser.applyMerchantIdPro = jsonResult.value(forKey: "applyMerchantIdPro") as! String
            
            User.currentUser.vendorGroupName = jsonResult.value(forKey: "vendorGroupName") as! String
            User.currentUser.mixPanelKey = jsonResult.value(forKey: "mixPanelKey") as! String
            User.currentUser.environment = jsonResult.value(forKey: "env") as! String
            
            //init stripe client
            STPPaymentConfiguration.shared().publishableKey = (User.currentUser.environment == "Development") ? User.currentUser.stripeTestKey : User.currentUser.stripePublishKey
            
            STPPaymentConfiguration.shared().appleMerchantIdentifier = (User.currentUser.environment == "Development") ? User.currentUser.applyMerchantIdDev : User.currentUser.applyMerchantIdPro
            
            //init mixpanel
            Mixpanel.initialize(token: User.currentUser.mixPanelKey)
            let mixpanel =  Mixpanel.mainInstance()
            if(User.currentUser.isLogin){
              mixpanel.identify(distinctId: User.currentUser.id, usePeople: true)
            }else{
              mixpanel.identify(distinctId: mixpanel.distinctId)
            }
            
            //add Observer for remove notification
            NotificationCenter.default.addObserver(self, selector: #selector(self.RegisterForAPNS(withNotification:)), name:AppNotifications.notificationRegisterAPNS, object: nil)
            
          } catch {}
        } catch {}
      }
    }
  
    //Register APNS
    func RegisterForAPNS(withNotification obj : NSNotification) {
      UIApplication.shared.registerForRemoteNotifications()
    }
  
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      let strDeviceToken = deviceToken.reduce("", {$0 + String(format: "%02.2hhx", $1)})
      print("DeviceToken===\(strDeviceToken)")
      if strDeviceToken.trim().isEmpty {
        UserDefaults.standard.set("", forKey: "DeviceToken")
        UserDefaults.standard.synchronize()
      }
      else {
        let mixpanel =  Mixpanel.mainInstance()
        if(User.currentUser.isLogin){
          mixpanel.identify(distinctId: User.currentUser.id, usePeople: true)
        }else{
          mixpanel.identify(distinctId: mixpanel.distinctId)
        }
        User.currentUser.deviceToken = strDeviceToken
        mixpanel.people.addPushDeviceToken(deviceToken)
        UserDefaults.standard.set(strDeviceToken, forKey: "DeviceToken")
        UserDefaults.standard.synchronize()
      }
    }
    
    func handleNotification(userInfo: [AnyHashable : Any])
    {
      print("userInfo = \(userInfo)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

