//
//  MainViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIPageViewControllerDataSource, MainViewControllerDelegate {
    
    var pageViewController: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.navigationController?.navigationBarHidden = true
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("GeneralPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        let eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
        eventListViewController.delegate = self
        let viewControllers = [eventListViewController]
        self.pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = self.view.frame
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Page View Data Source
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        switch viewController {
        case is EventListViewController:
            let messageListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MessageListViewController") as! MessageListViewController
            messageListViewController.delegate = self
            
            return messageListViewController
        case is MeViewController:
            let eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
            eventListViewController.delegate = self
            return eventListViewController
        default: return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is EventListViewController:
            let meViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MeViewController") as! MeViewController
            meViewController.delegate = self
            
            return meViewController
        case is MessageListViewController:
            let eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
            eventListViewController.delegate = self
            return eventListViewController
        default: return nil

        }
    }
    
    // Main View Controller Delegates
    func goToMe() {
        print("go to me")
        let meViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MeViewController") as! MeViewController
        meViewController.delegate = self
        
        self.pageViewController.setViewControllers([meViewController], direction: .Forward, animated: true, completion: nil)
    }
    
    func goToEvent(from vc: UIViewController) {
        let eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
        eventListViewController.delegate = self
        
        switch vc {
        case is MeViewController:
            self.pageViewController.setViewControllers([eventListViewController], direction: .Reverse, animated: true, completion: nil)
        case is MessageListViewController:
            self.pageViewController.setViewControllers([eventListViewController], direction: .Forward, animated: true, completion: nil)
        default: break
        }
    }
    
    func goToMessage() {
        print("go to message")
        let messageListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MessageListViewController") as! MessageListViewController
        messageListViewController.delegate = self
        
        self.pageViewController.setViewControllers([messageListViewController], direction: .Reverse, animated: true, completion: nil)
    }
}

protocol MainViewControllerDelegate {
    func goToMessage()
    func goToMe()
    func goToEvent(from vc: UIViewController)
}
