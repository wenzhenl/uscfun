//
//  MainViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var pageViewController: UIPageViewController!
    var currentViewController: UIViewController?
    var eventListViewController: EventListViewController!
    var messageListViewController: MessageListViewController!
    var meViewController: MeViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        self.title = "USC日常"
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.pageViewController = self.storyboard!.instantiateViewController(withIdentifier: "GeneralPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        messageListViewController = self.storyboard!.instantiateViewController(withIdentifier: "MessageListViewController") as! MessageListViewController
        messageListViewController.delegate = self
        
        eventListViewController = self.storyboard!.instantiateViewController(withIdentifier: "EventListViewController") as! EventListViewController
        eventListViewController.delegate = self
        
        meViewController = self.storyboard!.instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
        meViewController.delegate = self
        
        let viewControllers = [eventListViewController!]
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        self.pageViewController.view.frame = self.view.frame
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        for someview in self.pageViewController.view.subviews {
            if someview is UIScrollView {
                let scrollview = someview as! UIScrollView
                scrollview.delegate = self
            }
        }
    }
}

extension MainViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        switch viewController {
        case is EventListViewController:
            return messageListViewController
            
        case is MeViewController:
            return eventListViewController
            
        default: return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case is EventListViewController:
            return meViewController
            
        case is MessageListViewController:
            return eventListViewController
            
        default: return nil
            
        }
    }
}

extension MainViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        self.currentViewController = pageViewController.viewControllers!.first!
        switch self.currentViewController {
        case is EventListViewController:
            self.title = "USC日常"
        case is MessageListViewController:
            self.title = "消息队列"
        default:
            self.title = "我"
        }
    }
}

extension MainViewController: UIScrollViewDelegate {
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

extension MainViewController: MainViewControllerDelegate {
    func goToMessage() {
        
        self.pageViewController.setViewControllers([messageListViewController], direction: .reverse, animated: true) {
            completed in
            if completed {
                self.currentViewController = self.messageListViewController
            }
        }
    }
    
    func goToMe() {
        
        self.pageViewController.setViewControllers([meViewController], direction: .forward, animated: true) {
            completed in
            if completed {
                self.currentViewController = self.meViewController
            }
        }
    }
    
    func goToEvent(from vc: UIViewController) {
        
        switch vc {
        case is MeViewController:
            self.pageViewController.setViewControllers([eventListViewController], direction: .reverse, animated: true) {
                completed in
                if completed {
                    self.currentViewController = self.eventListViewController
                }
            }
        case is MessageListViewController:
            self.pageViewController.setViewControllers([eventListViewController], direction: .forward, animated: true) {
                completed in
                if completed {
                    self.currentViewController = self.eventListViewController
                }
            }
        default: break
        }
    }
}
