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
    var systemNotificationClient: AVIMClient?
    var timer: Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //--MARK: register wechat account
        WXApi.registerApp("wx8f761834a81e3579")
        
        //--MARK: register leanclound account
//        AVOSCloud.setServiceRegion(.US)
//        LCChatKit.setAppId("PekMMQm8zL9QvMJgRicoeDJ9-MdYXbMMI", appKey: "SJMKewuanrMk3jF8bQg4aChy")
//        AVOSCloud.setApplicationId("PekMMQm8zL9QvMJgRicoeDJ9-MdYXbMMI", clientKey: "SJMKewuanrMk3jF8bQg4aChy")
//        AVOSCloud.setAllLogsEnabled(true)

        AVOSCloud.setServiceRegion(.CN)
        LCChatKit.setAppId("0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", appKey: "XRGhgA5IwbqTWzosKRh3nzRY")
        AVOSCloud.setApplicationId("0ddsmQXAJt5gVLLE604DtE4U-gzGzoHsz", clientKey: "XRGhgA5IwbqTWzosKRh3nzRY")
        
        AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        LCCKInputViewPluginTakePhoto.registerSubclass()
        LCCKInputViewPluginPickImage.registerSubclass()
        LCCKInputViewPluginLocation.registerSubclass()
                
        LoginKit.delegate = self
        
        
        /// check if it is a new version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("version: \(version)")
            if let currentVersion = UserDefaults.currentVersion {
                if currentVersion != version {
                    UserDefaults.currentVersion = version
                    UserDefaults.lastRateAppRemindedAt = Date()
                    UserDefaults.hasRatedApp = false
                }
            } else {
                UserDefaults.currentVersion = version
                UserDefaults.lastRateAppRemindedAt = Date()
                UserDefaults.hasRatedApp = false
            }
        }
        
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
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")

        timer?.invalidate()
        timer = nil
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        print("APPLICATION DID BECOME ACTIVE")
        
        let num = application.applicationIconBadgeNumber
        if num != 0 {
            let currentInstallation = AVInstallation.current()
            currentInstallation.setValue(0, forKey: "badge")
            var error: NSError?
            if currentInstallation.save(&error) {
                print("reset badge successfully")
            } else if error != nil {
                print(error!)
            }
            application.cancelAllLocalNotifications()
            application.applicationIconBadgeNumber = 0
        }
        
        /// save avatar eventually if failed before
        if UserDefaults.needToSaveAvatarEventually {
            UserDefaults.updateUserAvatar()
        }
        
        /// restart timer to update remaining time
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateRemainingTime), userInfo: nil, repeats: true)
        }
        
        /// clean public events if needed
        if UserDefaults.shouldCleanPublicEvents {
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            let loadVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: USCFunConstants.storyboardIdentifierOfLoadDataViewController)
            appDelegate.window?.rootViewController = loadVC
            appDelegate.window?.makeKeyAndVisible()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("application will terminate")
        
        UserDefaults.hasPreloadedMyOngoingEvents = false
        UserDefaults.hasPreloadedPublicEvents = false
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        print("didRegister notificationSettings")

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
    
    func updateRemainingTime() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "needToUpdateRemainingTime"), object: nil, userInfo: nil)
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
    
    func conversation(_ conversation: AVIMConversation, didReceiveUnread unread: Int) {
        
        print("fetching unread messages starts")
        
        if UserDefaults.shouldSkipUnreadAfterLaunch {
            conversation.markAsReadInBackground()
            UserDefaults.shouldSkipUnreadAfterLaunch = false
            return
        } else {
            if unread <= 0 {
                return
            }
            conversation.queryMessagesFromServer(withLimit: UInt(unread)) {
                objects, error in
                if let messages = objects as? [AVIMTypedMessage] {
                    for message in messages {
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
                
                if error != nil {
                    print(error!)
                }
            }
            conversation.markAsReadInBackground()
        }
        
        print("fetching unread messages ends")
    }
}

extension AppDelegate: LoginDelegate {
    func userDidLoggedIn() {
        
        /// should skip unread system notification messages
        UserDefaults.shouldSkipUnreadAfterLaunch = true
        UserDefaults.lastPublicEventsCleanedAt = Date()
        
        AVIMClient.setUserOptions([AVIMUserOptionUseUnread: true])

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
        
//        LCChatKit.sharedInstance().avatarImageViewCornerRadiusBlock = {
//            avatarImageViewSize in
//            if avatarImageViewSize.height > 0 {
//                return avatarImageViewSize.height / 2
//            }
//            return 5
//        }
        
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
            guard let conversationId = conversationController?.conversationId, let message = message else {
                print("something goes wrong with send message hook")
                completion?(true, nil)
                return
            }
            
            print("catched send message \(message)")
            
            var text = ""
            let mediaType = MessageMediaType(rawValue: Int(message.mediaType))!
            switch mediaType {
            case .plain:
                text = message.text ?? ""
            case .image:
                text = "[图片]"
            case .audio:
                text = "[语音信息]"
            case .video:
                text = "[视频信息]"
            case .geolocation:
                text = "[位置]"
            case .file:
                text = "[文件]"
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newMessageForFinalizedEvents"), object: nil, userInfo: ["action": "send", "conversationId": conversationId, "text": text, "sendTimestamp": message.sendTimestamp])
            completion?(true, nil)
        }
        
        LCChatKit.sharedInstance().filterMessagesBlock = {
            conversation, messages, completion in
            guard let conversationId = conversation?.conversationId, let message = messages?.last else {
                print("something goes wrong with filter message hook")
                completion?(messages, nil)
                return
            }
            
            print("catched filtered message \(message)")
            
            guard message.clientId != AVUser.current()!.username else {
                print("my own message")
                completion?(messages, nil)
                return
            }
            
            var text = ""
            let mediaType = MessageMediaType(rawValue: Int(message.mediaType))!
            switch mediaType {
            case .plain:
                text = message.text ?? ""
            case .image:
                text = "[图片]"
            case .audio:
                text = "[语音信息]"
            case .video:
                text = "[视频信息]"
            case .geolocation:
                text = "[位置]"
            case .file:
                text = "[文件]"
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newMessageForFinalizedEvents"), object: nil, userInfo: ["action": "receive", "conversationId": conversationId, "text": text, "sendTimestamp": message.sendTimestamp])
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
        
        /// set AVIMClient to receive system broadcast
        /// The system client id is replace '@' and '.' with '_' in email
        /// and linked with '_sys', this should be the same id used to subscribe system 
        /// conversation during sign up
        systemNotificationClient = AVIMClient(clientId: AVUser.current()!.email!.systemClientId!)
        systemNotificationClient?.delegate = self
        systemNotificationClient?.open() {
            succeed, error in
            if succeed {
                print("system client open successfully")
            }
            
            if error != nil {
                print(error!)
            }
        }
    }
}
