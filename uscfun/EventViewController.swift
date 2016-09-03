//
//  EventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/2/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.insertSubview(blurView, atIndex: 1)
//        UIApplication.sharedApplication().statusBarHidden = true
        
//        self.navigationController!.navigationBar.barTintColor = UIColor.themeYellow()
//        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        self.navigationController!.navigationBar.shadowImage = UIImage()
//        self.navigationController!.navigationBar.tintColor = UIColor.darkGrayColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Event Display Cell") as! EventTableViewCell
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
}
