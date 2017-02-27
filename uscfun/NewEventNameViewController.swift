//
//  NewEventNameViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 2/27/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class NewEventNameViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var placeholderLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        self.automaticallyAdjustsScrollViewInsets = false
        self.textView.delegate = self
        self.textView.textContainer.lineFragmentPadding = 0
        self.textView.text = UserDefaults.newEventName
        if self.textView.text == "" {
            placeholderLabel.text = "请写下你要发起的微活动名称"
        } else {
            placeholderLabel.text = ""
        }
        if self.textView.text != "" {
            nextBarButton.isEnabled = true
        } else {
            nextBarButton.isEnabled = false
        }
        self.textView.becomeFirstResponder()
    }
    
    @IBAction func close() {
        self.textView.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension NewEventNameViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        if self.textView.text == "" {
            placeholderLabel.text = "请写下你要发起的微活动名称"
        } else {
            placeholderLabel.text = ""
        }
        
        if self.textView.text != "" {
            nextBarButton.isEnabled = true
        } else {
            nextBarButton.isEnabled = false
        }
        
        UserDefaults.newEventName = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        return true
    }
}
