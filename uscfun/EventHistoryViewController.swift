//
//  EventHistoryViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/14/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

enum EventHistorySource {
    case created
    case attended
}

class EventHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var eventHistorySource: EventHistorySource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.backgroundColor = UIColor.white
        
//        eventHistorySource = .created
    }
}
