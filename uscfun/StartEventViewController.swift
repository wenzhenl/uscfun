//
//  StartEventViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 9/4/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class StartEventViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let eventTitleTextViewTag = 1
    let numberOfRowInSection = [1,1,1,1]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.barTintColor = UIColor.buttonBlue()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
        self.view.backgroundColor = UIColor.backgroundGray()
        self.tableView.backgroundColor = UIColor.backgroundGray()
        self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        } else {
            return 100
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        } else {
            return 100
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfRowInSection.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowInSection[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("EventTitleCell") as! EventTitleTableViewCell
            cell.textView.delegate = self
            cell.textView.tag = eventTitleTextViewTag
            return cell
        } else if indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NumberTableViewCell") as! NumberTableViewCell
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clearColor()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: - TextView delegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
//    func textViewDidBeginEditing(textView: UITextView) {
//        if textView.textColor == UIColor.lightGrayColor() {
//            textView.text = nil
//            textView.textColor = UIColor.darkGrayColor()
//        }
//    }
    
//    func textViewDidEndEditing(textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = eventTitleTextViewPlaceHolder
//            textView.textColor = UIColor.lightGrayColor()
//        }
//    }
    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        
//        if(text == "\n") {
//            textView.resignFirstResponder()
//            return false
//        }
//        
//        // Combine the textView text and the replacement text to
//        // create the updated text string
//        let currentText: NSString = textView.text
//        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
//        
//        // If updated text view will be empty, add the placeholder
//        // and set the cursor to the beginning of the text view
//        if updatedText.isEmpty {
//            
//            textView.text = eventTitleTextViewPlaceHolder
//            textView.textColor = UIColor.lightGrayColor()
//            
//            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
//            
//            return false
//        }
//            
//            // Else if the text view's placeholder is showing and the
//            // length of the replacement string is greater than 0, clear
//            // the text view and set its color to black to prepare for
//            // the user's entry
//        else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
//            textView.text = nil
//            textView.textColor = UIColor.blackColor()
//        }
//        
//        return true
//    }
    
//    func textViewDidChangeSelection(textView: UITextView) {
//        if textView.textColor == UIColor.lightGrayColor() {
//            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
//        }
//    }
}
