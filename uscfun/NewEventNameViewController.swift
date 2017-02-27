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
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    @IBOutlet weak var placeholderLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
//        self.navigationController?.navigationBar.barTintColor = UIColor.red
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor]
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blue, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)]
//        leftBarButton.titleTextAttributes(for: <#T##UIControlState#>)
        self.automaticallyAdjustsScrollViewInsets = false
        self.textView.delegate = self
        self.textView.textContainer.lineFragmentPadding = 0
//        self.textView.textContainerInset = UIEdgeInsets.zero
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
    }
}
