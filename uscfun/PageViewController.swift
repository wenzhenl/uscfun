//
//  PageViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/11/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

protocol ViewControllerProvider {
    var initialViewController: UIViewController { get }
    func viewControllerAtIndex(_ index: Int) -> UIViewController?
}

struct WelcomeCard {
    var image: UIImage
    var showButton: Bool
}

class PageViewController: UIViewController {
    @IBOutlet weak var pageControl: UIPageControl!
    var pageContainer: UIPageViewController!
    
    var welcomeCards = [WelcomeCard]()
    
    fileprivate var pendingIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = true
        view.backgroundColor = UIColor.themeYellow
        let welcomeCard1 = WelcomeCard(image: #imageLiteral(resourceName: "welcome1"), showButton: false)
        let welcomeCard2 = WelcomeCard(image: #imageLiteral(resourceName: "welcome2"), showButton: false)
        let welcomeCard3 = WelcomeCard(image: #imageLiteral(resourceName: "welcome3"), showButton: false)
        let welcomeCard4 = WelcomeCard(image: #imageLiteral(resourceName: "welcome4"), showButton: true)
        welcomeCards.append(welcomeCard1)
        welcomeCards.append(welcomeCard2)
        welcomeCards.append(welcomeCard3)
        welcomeCards.append(welcomeCard4)

        pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageContainer.delegate = self
        pageContainer.dataSource = self
        pageContainer.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        
        view.addSubview(pageContainer.view)
        view.bringSubview(toFront: pageControl)
        
        pageControl.currentPageIndicatorTintColor = UIColor.themeYellow
        pageControl.tintColor = UIColor.darkText
        pageControl.isUserInteractionEnabled = false
        pageControl.numberOfPages = welcomeCards.count
        pageControl.currentPage = 0
    }
}

extension PageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? CardViewController, let pageIndex = viewController.pageIndex, pageIndex > 0 {
            return viewControllerAtIndex(pageIndex - 1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? CardViewController, let pageIndex = viewController.pageIndex, pageIndex < welcomeCards.count - 1 {
            return viewControllerAtIndex(pageIndex + 1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = (pendingViewControllers.first! as! CardViewController).pageIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let index = pendingIndex {
                pageControl.currentPage = index
            }
        }
    }
}

// MARK: View controller provider

extension PageViewController: ViewControllerProvider {
    
    var initialViewController: UIViewController {
        return viewControllerAtIndex(0)!
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        
        if let cardViewController = UIStoryboard(name: "Welcome", bundle: nil).instantiateViewController(withIdentifier: "card view controller") as? CardViewController {
            
            cardViewController.pageIndex = index
            cardViewController.welcomeCard = welcomeCards[index]
            
            return cardViewController
        }
        
        return nil
    }
}
