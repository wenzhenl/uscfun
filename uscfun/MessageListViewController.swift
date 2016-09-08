//
//  MessageListViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/5/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class MessageListViewController: UIViewController {

    var delegate: MainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        self.navigationController!.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
//        self.navigationController!.navigationBarHidden = true
    }

    @IBAction func goEvent(sender: UIButton) {
        delegate?.goToEvent(from: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
