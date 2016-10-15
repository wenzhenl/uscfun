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
        UIApplication.shared.statusBarStyle = .lightContent
//        self.navigationController?.isNavigationBarHidden = true
        self.title = ""
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.pageViewController = self.storyboard!.instantiateViewController(withIdentifier: "GeneralPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        let eventListViewController = self.storyboard!.instantiateViewController(withIdentifier: "EventListViewController") as! EventListViewController
        eventListViewController.delegate = self
        let viewControllers = [eventListViewController]
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        self.pageViewController.view.frame = self.view.frame
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
        for someview in self.pageViewController.view.subviews {
            if someview is UIScrollView {
                let sv = someview as! UIScrollView
                sv.delegate = self
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: - Page View Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        switch viewController {
        case is EventListViewController:
            let messageListViewController = self.storyboard!.instantiateViewController(withIdentifier: "MessageListViewController") as! MessageListViewController
            messageListViewController.delegate = self
            
            return messageListViewController
        case is MeViewController:
            let eventListViewController = self.storyboard!.instantiateViewController(withIdentifier: "EventListViewController") as! EventListViewController
            eventListViewController.delegate = self
            return eventListViewController
        default: return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is EventListViewController:
            let meViewController = self.storyboard!.instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
            meViewController.delegate = self
            
            return meViewController
        case is MessageListViewController:
            let eventListViewController = self.storyboard!.instantiateViewController(withIdentifier: "EventListViewController") as! EventListViewController
            eventListViewController.delegate = self
            return eventListViewController
        default: return nil

        }
    }
    
    //MARK: - Page View Delegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        self.currentViewController = pageViewController.viewControllers!.first!
    }
    
    //MARK: - Main View Controller Delegates
    func goToMe() {
        let meViewController = self.storyboard!.instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
        meViewController.delegate = self
        
        self.pageViewController.setViewControllers([meViewController], direction: .forward, animated: true) {
            completed in
            if completed {
                self.currentViewController = meViewController
            }
        }
    }
    
    func goToEvent(from vc: UIViewController) {
        let eventListViewController = self.storyboard!.instantiateViewController(withIdentifier: "EventListViewController") as! EventListViewController
        eventListViewController.delegate = self
        
        switch vc {
        case is MeViewController:
            self.pageViewController.setViewControllers([eventListViewController], direction: .reverse, animated: true) {
                completed in
                if completed {
                    self.currentViewController = eventListViewController
                }
            }
        case is MessageListViewController:
            self.pageViewController.setViewControllers([eventListViewController], direction: .forward, animated: true) {
                completed in
                if completed {
                    self.currentViewController = eventListViewController
                }
            }
        default: break
        }
    }
    
    func goToMessage() {
        let messageListViewController = self.storyboard!.instantiateViewController(withIdentifier: "MessageListViewController") as! MessageListViewController
        messageListViewController.delegate = self
        self.pageViewController.setViewControllers([messageListViewController], direction: .reverse, animated: true) {
            completed in
            if completed {
                self.currentViewController = messageListViewController
            }
        }
    }
    
    // MARK: - UIScrollView delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let currentVC = currentViewController {
            if currentVC is MessageListViewController && (scrollView.contentOffset.x < scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
            } else if currentVC is MeViewController && (scrollView.contentOffset.x > scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let currentVC = currentViewController {
            if currentVC is MessageListViewController && (scrollView.contentOffset.x < scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
            } else if currentVC is MeViewController && (scrollView.contentOffset.x > scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
            }
        }

    }
}

protocol MainViewControllerDelegate {
    func goToMessage()
    func goToMe()
    func goToEvent(from vc: UIViewController)
}
