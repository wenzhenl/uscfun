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
    var title: String
    var subtitle: String
    var backgroundColor: UIColor
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
        view.backgroundColor = UIColor.avatarGolden
        let welcomeCard1 = WelcomeCard(image: #imageLiteral(resourceName: "welcome1"), title: "无论是", subtitle: "十分钟后韩国城一起吃午饭", backgroundColor: UIColor.avatarGolden, showButton: false)
        let welcomeCard2 = WelcomeCard(image: #imageLiteral(resourceName: "welcome1"), title: "还是", subtitle: "这周末的hiking", backgroundColor: UIColor.avatarTomato, showButton: false)
        let welcomeCard3 = WelcomeCard(image: #imageLiteral(resourceName: "welcome1"), title: "我们都", subtitle: "我们聚集USC的小伙伴们一起行动", backgroundColor: UIColor.avatarBlue, showButton: false)
        let welcomeCard4 = WelcomeCard(image: #imageLiteral(resourceName: "welcome1"), title: "我们都", subtitle: "我们聚集USC的小伙伴们一起行动", backgroundColor: UIColor.avatarGolden, showButton: true)
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
