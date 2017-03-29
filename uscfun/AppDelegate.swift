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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //--MARK: register for notification
        registerForPushNotifications(application: application)
        //--MARK: register wechat account
        WXApi.registerApp("wx8f761834a81e3579")
        
        //--MARK: register leanclound account
        AVOSCloud.setServiceRegion(.CN)
        LCChatKit.setAppId("0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", appKey: "XRGhgA5IwbqTWzosKRh3nzRY")
        AVOSCloud.setApplicationId("0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", clientKey: "XRGhgA5IwbqTWzosKRh3nzRY")
        AVOSCloud.setAllLogsEnabled(true)
        AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        LCCKInputViewPluginTakePhoto.registerSubclass()
        LCCKInputViewPluginPickImage.registerSubclass()
        LCCKInputViewPluginLocation.registerSubclass()
                
        LoginKit.delegate = self
        
        // PRE-LOAD DATA
        if UserDefaults.hasLoggedIn {
            userDidLoggedIn()
            EventRequest.preLoadData()
            UserDefaults.hasPreloadedMyOngoingEvents = true
            UserDefaults.hasPreloadedPublicEvents = true
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
        
        print("APPLICATION DID BECOME ACTIVE")
        let num = application.applicationIconBadgeNumber
        if num != 0 {
            let currentInstallation = AVInstallation.current()
            currentInstallation.setValue(0, forKey: "badge")
            currentInstallation.saveEventually()
            application.cancelAllLocalNotifications()
            application.applicationIconBadgeNumber = 0
        }
        
        /// save avatar eventually if failed before
        if UserDefaults.needToSaveAvatarEventually {
            UserDefaults.updateUserAvatar()
        }
        
        if UserDefaults.hasLoggedIn {
            let cleanGroup = DispatchGroup()
            cleanGroup.enter()
            /// clean non-valid events
            EventRequest.cleanEventsInBackground(for: .myongoing) {
                cleanGroup.leave()
            }
            cleanGroup.enter()
            EventRequest.cleanEventsInBackground(for: .mypublic) {
                cleanGroup.leave()
            }
            cleanGroup.notify(queue: DispatchQueue.main) {
                print("clean events finished")
            }
            print("thank god, cleaning finally finished")
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.hasPreloadedMyOngoingEvents = false
        UserDefaults.hasPreloadedPublicEvents = false
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
    func conversation(_ conversation: AVIMConversation, didReceive message: AVIMTypedMessage) {
        print(message.text ?? "")
        
        guard let reason = message.attributes?["reason"] as? String, let eventId = message.attributes?["eventId"] as? String else {
            print("cannot parse message attributes")
            return
        }
        
        if reason == "new" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newEventAvailable"), object: nil, userInfo: ["eventId": eventId])
        }
        else if reason == "updated" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedEventAvailable"), object: nil, userInfo: ["eventId": eventId])
        }
    }
}

extension AppDelegate: LoginDelegate {
    func userDidLoggedIn() {
        
        LCChatKit.sharedInstance().fetchProfilesBlock = {
            userIds, completionHandler in
            var users = [LCCKUser]()
            if let userIds = userIds {
                let query = AVQuery(className: "_User")
                query.whereKey("username", containedIn: userIds)
                if let objects = query.findObjects() {
                    for object in objects as! [AVUser] {
                        let user = LCCKUser(userId: object.value(forKey: UserKeyConstants.keyOfNickname) as! String!, name: object.value(forKey: UserKeyConstants.keyOfNickname) as! String!, avatarURL: URL(string: object.value(forKey: UserKeyConstants.keyOfAvatarUrl) as! String))
                        users.append(user!)
                    }
                }
            }
            if completionHandler != nil {
                completionHandler!(users, nil)
            }
        }
        
        LCChatKit.sharedInstance().fetchConversationHandler = {
            conversation, conversationController in
            if conversation == nil {
                print("cannot fetch conversation")
            } else {
                SVProgressHUD.show()
                print("successfully fetched conversation")
            }
        }
        
        LCChatKit.sharedInstance().conversationInvalidedHandler = {
            conversationId, vc, user, error in
            print(error!)
        }
        
        LCChatKit.sharedInstance().loadLatestMessagesHandler = {
            conversationController, succeeded, error in
            SVProgressHUD.dismiss()
            print("load latest message handler successfully")
        }
        
        LCChatKit.sharedInstance().disableSingleSignOn = true
        
        LCChatKit.sharedInstance().avatarImageViewCornerRadiusBlock = {
            avatarImageViewSize in
            if avatarImageViewSize.height > 0 {
                return avatarImageViewSize.height / 2
            }
            return 5
        }
        
        LCChatKit.sharedInstance().openProfileBlock = {
            userId, id, parentViewController in
            guard let userId = userId else { return }
            let userProfileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfUserProfilerViewController) as! UserProfileViewController
            let query = AVQuery(className: "_User")
            query.whereKey("username", equalTo: userId)
            guard let objects = query.findObjects(), objects.count > 0, let user = objects[0] as? AVUser else { return }
            userProfileVC.user = user
            parentViewController?.navigationController?.pushViewController(userProfileVC, animated: true)
        }
        
        LCChatKit.sharedInstance().previewLocationMessageBlock = {
            location, geolocations, userInfo in
            let mapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfMapViewController) as! MapViewController
            mapVC.latitude = location?.coordinate.latitude
            mapVC.longitude = location?.coordinate.longitude
            mapVC.placename = geolocations
            if let fromController = userInfo?["LCCKPreviewLocationMessageUserInfoKeyFromController"] as? UIViewController {
                fromController.navigationController?.pushViewController(mapVC, animated: true)
            }
        }
        
        LCChatKit.sharedInstance().sendMessageHookBlock = {
            conversationController, message, completion in
            guard let conversationId = conversationController?.conversationId, let text = message?.text else {
                print("something goes wrong with send message hook")
                completion?(true, nil)
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newMessageForFinalizedEvents"), object: nil, userInfo: ["action": "send", "conversationId": conversationId, "text": text])
            completion?(true, nil)
        }
        
        LCChatKit.sharedInstance().filterMessagesBlock = {
            conversation, messages, completion in
            guard let conversationId = conversation?.conversationId, let text = messages?.last?.text else {
                print("something goes wrong with filter message hook")
                completion?(messages, nil)
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newMessageForFinalizedEvents"), object: nil, userInfo: ["action": "receive", "conversationId": conversationId, "text": text])
            completion?(messages, nil)
        }
        
        LCChatKit.sharedInstance().open(withClientId: AVUser.current()!.username!) {
            succeed, error in
            if succeed {
                print("LCChatKit open successfully")
            }
            
            if error != nil {
                print(error!.localizedDescription)
            }
        }

        // set AVIMClient to receive system broadcast
        client = AVIMClient(clientId: UserDefaults.email!)
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
    }
}
