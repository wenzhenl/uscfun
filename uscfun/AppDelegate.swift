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
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var client: AVIMClient?
    
    static var systemNotificationDelegate: SystemNotificationDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //--MARK: register for notification
        registerForPushNotifications(application: application)
        //--MARK: register wechat account
        WXApi.registerApp("wx8f761834a81e3579")
        
        //--MARK: register leanclound account
        AVOSCloud.setServiceRegion(.CN)
        
        LCChatKit.setAppId("0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", appKey: "XRGhgA5IwbqTWzosKRh3nzRY")
        AVOSCloud.setApplicationId("0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", clientKey: "XRGhgA5IwbqTWzosKRh3nzRY")
        AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        LCCKInputViewPluginTakePhoto.registerSubclass()
        LCCKInputViewPluginPickImage.registerSubclass()
        LCCKInputViewPluginLocation.registerSubclass()
        
        LoginKit.delegate = self
        
        // PRE-LOAD DATA
        if UserDefaults.hasLoggedIn {
            userDidLoggedIn()
            EventRequest.preLoadData()
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
    
//        window = UIWindow(frame: UIScreen.main.bounds)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let initialViewController = storyboard.instantiateInitialViewController()
//        window?.rootViewController = initialViewController
//        window?.makeKeyAndVisible()
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
        
        print("APPLICATION DID BECOME ACTIVE")
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
}

extension AppDelegate: WXApiDelegate {
    func onReq(_ req: BaseReq!) {
    }
    
    func onResp(_ resp: BaseResp!) {
    }
}

extension AppDelegate: AVIMClientDelegate {
    func conversation(_ conversation: AVIMConversation!, didReceive message: AVIMTypedMessage!) {
        print(message.text)
        SVProgressHUD.showInfo(withStatus: message.text)
        let delay = 3 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            SVProgressHUD.dismiss()
        }
        
        if let concatenatedUpdatedIds = message.attributes[EventKeyConstants.keyOfSystemNotificationOfUpdatedEvents] as? String {
            let updatedIds = concatenatedUpdatedIds.components(separatedBy: ",")
            var existingEventsIds = [String]()
            var newEventsIds = [String]()
            
            for id in updatedIds {
                print(id)
                if EventRequest.myOngoingEvents.keys.contains(id) || EventRequest.publicEvents.keys.contains(id) {
                    existingEventsIds.append(id)
                } else {
                    newEventsIds.append(id)
                }
            }
            
            if existingEventsIds.count > 0 {
                AppDelegate.systemNotificationDelegate?.systemDidUpdateExistingEvents(ids: existingEventsIds)
            }
            
            if newEventsIds.count > 0 {
                AppDelegate.systemNotificationDelegate?.systemDidUpdateNewEvents()
            }
        }
    }
}

extension AppDelegate: LoginDelegate {
    func userDidLoggedIn() {
        
        LCChatKit.sharedInstance().fetchProfilesBlock = {
            userIds, completionHandler in
            var users = [LCCKUser]()
            if let userIds = userIds {
                if let query = AVQuery(className: "_User") {
                    query.whereKey("username", containedIn: userIds)
                    if let objects = query.findObjects() {
                        for object in objects as! [AVUser] {
                            let user = LCCKUser(userId: object.value(forKey: UserKeyConstants.keyOfNickname) as! String!, name: object.value(forKey: UserKeyConstants.keyOfNickname) as! String!, avatarURL: URL(string: object.value(forKey: UserKeyConstants.keyOfAvatarUrl) as! String))
                            users.append(user!)
                        }
                    }
                }
            }
            if completionHandler != nil {
                completionHandler!(users, nil)
            }
        }
        
        LCChatKit.sharedInstance().fetchConversationHandler = {
            conversation, error in
            if conversation == nil {
                print("cannot fetch conversation")
            } else {
                print("successfully fetched conversation")
            }
        }
        
        LCChatKit.sharedInstance().conversationInvalidedHandler = {
            conversationId, vc, user, error in
            print(error!)
        }
        
        LCChatKit.sharedInstance().disableSingleSignOn = true
        
        // set AVIMClient to receive system broadcast
        client = AVIMClient(clientId: AVUser.current().username + "_system_notification")
        client?.delegate = self
        client?.open() {
            succeed, error in
            if succeed {
                print("client open successfully")
            }
            
            if error != nil {
                print(error!.localizedDescription)
            }
        }
        
        LCChatKit.sharedInstance().open(withClientId: AVUser.current().username) {
            succeed, error in
            if succeed {
                print("LCChatKit open successfully")
            }
            
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
