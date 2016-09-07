//
//  MainViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, EventListViewControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        
        let meViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MeViewController") as! MeViewController
        let eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
        let messageListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MessageListViewController") as! MessageListViewController
        
        self.addChildViewController(meViewController)
        self.scrollView.addSubview(meViewController.view)
        meViewController.didMoveToParentViewController(self)
        
        self.addChildViewController(eventListViewController)
        self.scrollView.addSubview(eventListViewController.view)
        eventListViewController.didMoveToParentViewController(self)
        
        self.addChildViewController(messageListViewController)
        self.scrollView.addSubview(messageListViewController.view)
        messageListViewController.didMoveToParentViewController(self)
        
        eventListViewController.view.frame.origin.x = self.view.frame.size.width
        eventListViewController.view.frame.size.width = self.view.frame.size.width
        meViewController.view.frame.origin.x = self.view.frame.size.width * 2
        eventListViewController.delegate = self
        
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height - 22)
        self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0)
        print("view did layout subviews")
    }
    
    func goToMessage() {
        UIView.animateWithDuration(0.35, animations: {
            self.scrollView.contentOffset = CGPointMake(0, 0)
        })
    }
    
    func goToMe() {
        UIView.animateWithDuration(0.35, animations: {
            self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width * 2, 0)
        })
    }
}
