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
    
    var eventName: String {
        get {
            return (textView.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        set {
            textView.text = newValue
            nextBarButton.isEnabled = !newValue.isEmpty
            placeholderLabel.text = newValue.isEmpty ? "请写下你要发起的微活动名称" : ""
            UserDefaults.newEventName = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        self.automaticallyAdjustsScrollViewInsets = false
        self.textView.delegate = self
        self.textView.textContainer.lineFragmentPadding = 0
        eventName = UserDefaults.newEventName ?? ""
        self.textView.becomeFirstResponder()
    }
    
    @IBAction func goNext(_ sender: UIBarButtonItem) {
        if eventName.characters.count >= 4 && eventName.characters.count <= 140 {
            performSegue(withIdentifier: "BeginEditingNewEventDue", sender: self)
        }
    }
    
    @IBAction func close() {
        self.textView.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension NewEventNameViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil {
            eventName = textView.text
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        return true
    }
}
