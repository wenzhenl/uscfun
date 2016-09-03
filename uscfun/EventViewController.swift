//
//  EventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/2/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var eventTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.tintColor = UIColor.darkGrayColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(17)]
        self.view.backgroundColor = UIColor.backgroundGray()
//        eventTableView.rowHeight = UITableViewAutomaticDimension
//        eventTableView.estimatedRowHeight = 200
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Event Display Cell") as! EventTableViewCell
        cell.selectionStyle = .None
        // randomize view color
        let blueColor = CGFloat(Int(arc4random() % 255)) / 255.0
        let greenColor = CGFloat(Int(arc4random() % 255)) / 255.0
        let redColor = CGFloat(Int(arc4random() % 255)) / 255.0
        
        cell.containerView.backgroundColor = UIColor(red: redColor, green: greenColor, blue: blueColor, alpha: 0.7)
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
//        return UITableViewAutomaticDimension
    }
    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
}
