//
//  MainViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, MainViewControllerDelegate, UIScrollViewDelegate {
    
    var pageViewController: UIPageViewController!
    var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        self.navigationController?.navigationBarHidden = true
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.pageViewController = self.storyboard!.instantiateViewControllerWithIdentifier("GeneralPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        let eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
        eventListViewController.delegate = self
        let viewControllers = [eventListViewController]
        self.pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = self.view.frame
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        for someview in self.pageViewController.view.subviews {
            if someview is UIScrollView {
                let sv = someview as! UIScrollView
                sv.delegate = self
            }
        }
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
    
    //MARK: - Page View Delegate
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        self.currentViewController = pageViewController.viewControllers!.first!
        print(self.currentViewController)
    }
    
    //MARK: - Main View Controller Delegates
    func goToMe() {
        print("go to me")
        let meViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MeViewController") as! MeViewController
        meViewController.delegate = self
        
        self.pageViewController.setViewControllers([meViewController], direction: .Forward, animated: true) {
            completed in
            if completed {
                self.currentViewController = meViewController
            }
        }
    }
    
    func goToEvent(from vc: UIViewController) {
        let eventListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventListViewController") as! EventListViewController
        eventListViewController.delegate = self
        
        switch vc {
        case is MeViewController:
            self.pageViewController.setViewControllers([eventListViewController], direction: .Reverse, animated: true) {
                completed in
                if completed {
                    self.currentViewController = eventListViewController
                }
            }
        case is MessageListViewController:
            self.pageViewController.setViewControllers([eventListViewController], direction: .Forward, animated: true) {
                completed in
                if completed {
                    self.currentViewController = eventListViewController
                }
            }
        default: break
        }
        print(self.currentViewController)
    }
    
    func goToMessage() {
        print("go to message")
        let messageListViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MessageListViewController") as! MessageListViewController
        messageListViewController.delegate = self
        self.pageViewController.setViewControllers([messageListViewController], direction: .Reverse, animated: true) {
            completed in
            if completed {
                self.currentViewController = messageListViewController
            }
        }
    }
    
    // MARK: - UIScrollView delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("yes, it enters")
        if let currentVC = currentViewController {
            if currentVC is MessageListViewController && (scrollView.contentOffset.x < scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
                print("label1")
            } else if currentVC is MeViewController && (scrollView.contentOffset.x > scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
                print("label2")
            }
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("yes, it ends")
        if let currentVC = currentViewController {
            if currentVC is MessageListViewController && (scrollView.contentOffset.x < scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
                print("label3")
            } else if currentVC is MeViewController && (scrollView.contentOffset.x > scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0)
                print("label4")
            }
        }

    }
}

protocol MainViewControllerDelegate {
    func goToMessage()
    func goToMe()
    func goToEvent(from vc: UIViewController)
}
