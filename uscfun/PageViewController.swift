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
    var note: String
}

class PageViewController: UIPageViewController {
    var welcomeCards = [WelcomeCard]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.themeYellow
        let welcomeCard1 = WelcomeCard(image: #imageLiteral(resourceName: "welcome1"), note: "welcome")
        welcomeCards.append(welcomeCard1)
        welcomeCards.append(welcomeCard1)
        welcomeCards.append(welcomeCard1)
        dataSource = self
        setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
    }
}

extension PageViewController: UIPageViewControllerDataSource {
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
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return welcomeCards.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
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
