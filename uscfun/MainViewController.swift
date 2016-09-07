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
    
    var meViewController: MeViewController!
    var eventListViewController: EventListViewController!
    var messageListViewController: MessageListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.navigationController?.navigationBarHidden = true
//        self.view.backgroundColor = UIColor.buttonBlue()
        
        meViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MeViewController") as! MeViewController
        eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
        messageListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MessageListViewController") as! MessageListViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewDidLayoutSubviews() {
        self.addChildViewController(meViewController)
        self.scrollView.addSubview(meViewController.view)
        meViewController.didMoveToParentViewController(self)
        
        self.addChildViewController(eventListViewController)
        self.scrollView.addSubview(eventListViewController.view)
        eventListViewController.didMoveToParentViewController(self)
        eventListViewController.delegate = self
        
        self.addChildViewController(messageListViewController)
        self.scrollView.addSubview(messageListViewController.view)
        messageListViewController.didMoveToParentViewController(self)
        
        eventListViewController.view.frame.origin.x = self.view.frame.size.width
        eventListViewController.view.frame.size.width = self.view.frame.size.width
        meViewController.view.frame.origin.x = self.view.frame.size.width * 2
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height - 44)
        self.scrollView.contentOffset.x = self.view.frame.size.width
        print("view will appear")
    }
    
    func goToMessage() {
        UIView.animateWithDuration(0.35, animations: {
            self.scrollView.contentOffset.x = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func goToMe() {
        UIView.animateWithDuration(0.35, animations: {
            self.scrollView.contentOffset.x = self.view.frame.size.width * 2
            self.view.layoutIfNeeded()
        })
    }
}
