//
//  AppDelegate.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import AVOSCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        //--MARK: register wechat account
        WXApi.registerApp("wx8f761834a81e3579")
        
        //--MARK: register leanclound account
        AVOSCloud.setServiceRegion(.US)
        
        AVOSCloud.setApplicationId("pDLnf6MjL1vIgRw6b2WWWVCJ-MdYXbMMI", clientKey: "zpbYwzEe5c6Cw4Ecmfr745C2")
        AVAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        let query = AVQuery(className: "Event")
//        query?.findObjectsInBackground() {
//            objects, error in
//            for object in objects! {
//                let avObj = object as! AVObject
//                print("myname:")
//                print(avObj["name"])
//            }
//        }
        let objects = query?.findObjects()
        for obj in objects! as! [AVObject]{
//            print("name:")
//            print(event.allKeys())
//            print(event.object(forKey: "name"))
            
//            if (event.allKeys() as! [String]).contains("name") {
//                print(event.object(forKey: "name"))
//            }
            if let event = Event(data: obj) {
                print(event.name)
            } else {
                print("cannot create event")
            }
        }
        
        // choose login scene or home scene based on if loggedin
        window = UIWindow(frame: UIScreen.main.bounds)
        if User.hasLoggedIn {
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func onReq(_ req: BaseReq!) {
    }
    
    func onResp(_ resp: BaseResp!) {
    }
}
