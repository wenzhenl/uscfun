//
//  AppDelegate.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import AVOSCloud
import ChatKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        //--MARK: register for notification
        registerForPushNotifications(application: application)
        //--MARK: register wechat account
        WXApi.registerApp("wx8f761834a81e3579")
        
        //--MARK: register leanclound account
        AVOSCloud.setServiceRegion(.US)
        
        LCChatKit.setAppId("pDLnf6MjL1vIgRw6b2WWWVCJ-MdYXbMMI", appKey: "zpbYwzEe5c6Cw4Ecmfr745C2")
        AVOSCloud.setApplicationId("pDLnf6MjL1vIgRw6b2WWWVCJ-MdYXbMMI", clientKey: "zpbYwzEe5c6Cw4Ecmfr745C2")
        AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        LCCKInputViewPluginTakePhoto.registerSubclass()
        LCCKInputViewPluginPickImage.registerSubclass()
        LCCKInputViewPluginLocation.registerSubclass()
        LCChatKit.sharedInstance().fetchProfilesBlock = {
            userIds, completionHandler in
            var users = [LCCKUser]()
            if let userIds = userIds {
                for id in userIds {
                    print(id)
                    let user = LCCKUser(clientId: id)
                    users.append(user!)
                }
            }
            
            if completionHandler != nil {
                print("pass users")
                completionHandler!(users, nil)
            }
            
        }
        
        LCChatKit.sharedInstance().conversationInvalidedHandler = {
            conversationId, vc, user, error in
            print(error)
        }
        
        // choose login scene or home scene based on if loggedin
        window = UIWindow(frame: UIScreen.main.bounds)
        if UserDefaults.hasLoggedIn {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController()
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController()
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        let num = application.applicationIconBadgeNumber
        if num != 0 {
            if let currentInstallation = AVInstallation.current() {
                currentInstallation.setValue(0, forKey: "badge")
                currentInstallation.saveEventually()
            }
            application.cancelAllLocalNotifications()
            application.applicationIconBadgeNumber = 0
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types.contains(.alert) {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("deviceToken: \(deviceToken)")
        AVOSCloud.handleRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func onReq(_ req: BaseReq!) {
    }
    
    func onResp(_ resp: BaseResp!) {
    }
}
