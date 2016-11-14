//
//  MainViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/6/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MainViewController: EZSwipeController {
    
    let titles = ["消息队列", "USC日常", "我"]
    let barColors = [UIColor.buttonBlue, UIColor.buttonBlue, UIColor.buttonBlue]
    
    override func setupView() {
        super.setupView()
        datasource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.buttonBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        self.title = titles[self.currentVCIndex]
        for someview in self.pageViewController.view.subviews {
            if someview is UIScrollView {
                let scrollview = someview as! UIScrollView
                scrollview.delegate = self
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.title = ""
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = barColors[self.currentVCIndex]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}

extension MainViewController: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        
        let messageListViewController = self.storyboard!.instantiateViewController(withIdentifier: "MessageListViewController") as! MessageListViewController
        let  eventListViewController = self.storyboard!.instantiateViewController(withIdentifier: "EventListViewController") as! EventListViewController
        let meViewController = self.storyboard!.instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
        meViewController.delegate = eventListViewController
        
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
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let navigationItem = UINavigationItem(title: title!)
        navigationItem.hidesBackButton = true
        
        if index == 0 {
            let messageImage = #imageLiteral(resourceName: "forward").scaleTo(width: 22, height: 22)
            let rightButtonItem = UIBarButtonItem(image: messageImage, style: .plain, target: self, action: nil)
            rightButtonItem.tintColor = UIColor.white
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = rightButtonItem
            
        } else if index == 1 {
            let messageImage = #imageLiteral(resourceName: "message").scaleTo(width: 22, height: 22)
            let leftButtonItem = UIBarButtonItem(image: messageImage, style: .plain, target: self, action: nil)
            leftButtonItem.tintColor = UIColor.white
            
            let meImage = #imageLiteral(resourceName: "fatuser").scaleTo(width: 22, height: 22)
            let rightButtonItem = UIBarButtonItem(image: meImage, style: .plain, target: self, action: nil)
            rightButtonItem.tintColor = UIColor.white
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.rightBarButtonItem = rightButtonItem
            
        } else if index == 2 {
            let meImage = #imageLiteral(resourceName: "backward").scaleTo(width: 22, height: 22)
            let leftButtonItem = UIBarButtonItem(image: meImage, style: .plain, target: self, action: nil)
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
