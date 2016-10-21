//
//  MainViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit
import EZSwipeController

class MainViewController: EZSwipeController {
    
    let titles = ["消息队列", "USC日常", "我"]
    let barColors = [UIColor.buttonBlue, UIColor.buttonBlue, UIColor.buttonBlue]
    
    override func setupView() {
        datasource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.buttonBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        for someview in self.pageViewController.view.subviews {
            if someview is UIScrollView {
                let scrollview = someview as! UIScrollView
                scrollview.delegate = self
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = barColors[self.currentVCIndex]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    func a() {
        
    }
}

extension MainViewController: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        
        let messageListViewController = self.storyboard!.instantiateViewController(withIdentifier: "MessageListViewController") as! MessageListViewController
        let  eventListViewController = self.storyboard!.instantiateViewController(withIdentifier: "EventListViewController") as! EventListViewController
        let meViewController = self.storyboard!.instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
        return [messageListViewController, eventListViewController, meViewController]
    }
    
    func titlesForPages() -> [String] {
        return ["消息队列", "USC日常", "我"]
    }
    
    func navigationBarDataForPageIndex(_ index: Int) -> UINavigationBar {
        
   
        guard index >= 0, index < titles.count else {
            return UINavigationBar()
        }
        title = titles[index]
        
        let navigationBar = UINavigationBar()
        navigationBar.barStyle = UIBarStyle.default
        navigationBar.barTintColor = barColors[index]
        print(navigationBar.barTintColor)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let navigationItem = UINavigationItem(title: title!)
        navigationItem.hidesBackButton = true
        
        if index == 0 {
            let rightButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(a))
            rightButtonItem.tintColor = UIColor.white
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 1 {
            let rightButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.bookmarks, target: self, action: #selector(a))
            rightButtonItem.tintColor = UIColor.white
            
            let leftButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action: #selector(a))
            leftButtonItem.tintColor = UIColor.white
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 2 {
            let leftButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(a))
            leftButtonItem.tintColor = UIColor.white
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.rightBarButtonItem = nil
        }
        navigationBar.pushItem(navigationItem, animated: false)
        return navigationBar
    }
    
    func indexOfStartingPage() -> Int {
        return 1
    }
    
    func changedToPageIndex(_ index: Int) {
//        self.view.backgroundColor = barColors[index]
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.currentVCIndex == 0 && (scrollView.contentOffset.x < scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if self.currentVCIndex == self.stackVC.count - 1 && (scrollView.contentOffset.x > scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.currentVCIndex == 0 && (scrollView.contentOffset.x < scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if self.currentVCIndex == self.stackVC.count - 1 && (scrollView.contentOffset.x > scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }
}
