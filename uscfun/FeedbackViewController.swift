//
//  FeedbackViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/10/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    var feedback: String {
        get {
            return (textView.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        set {
            print("feedback is set")
            textView.text = newValue
            sendButton.isEnabled = !newValue.isEmpty
            UserDefaults.feedback = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedback = UserDefaults.feedback ?? ""
        textView.delegate = self
        textView.becomeFirstResponder()
    }
    @IBAction func sendFeedback(_ sender: UIBarButtonItem) {
        UserDefaults.sendFeedback()
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil {
            feedback = textView.text
        }
    }
}
