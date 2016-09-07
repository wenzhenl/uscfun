//
//  MainViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIPageViewControllerDataSource {
    
    var meViewController: MeViewController!
    var eventListViewController: EventListViewController!
    var messageListViewController: MessageListViewController!
    
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
            return messageListViewController
        case is MeViewController:
            let eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
            return eventListViewController
        default: return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is EventListViewController:
            let meViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MeViewController") as! MeViewController
            return meViewController
        case is MessageListViewController:
            let eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
            return eventListViewController
        default: return nil

        }
    }
}
