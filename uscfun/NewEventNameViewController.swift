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
    
    var errorLabel: UILabel!
    
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
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        
        if let navigationBar = self.navigationController?.navigationBar {
            errorLabel = UILabel(frame: CGRect(x: navigationBar.frame.width/4, y: 0, width: navigationBar.frame.width/2, height: navigationBar.frame.height))
            errorLabel.textAlignment = .center
            errorLabel.textColor = UIColor.red
            errorLabel.font = UIFont.systemFont(ofSize: 13)
            errorLabel.numberOfLines = 0
            navigationBar.addSubview(errorLabel)
            errorLabel.isHidden = true
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.textView.delegate = self
        self.textView.textContainer.lineFragmentPadding = 0
        eventName = UserDefaults.newEventName ?? ""
        self.textView.becomeFirstResponder()
    }
    
    @IBAction func goNext() {
        if eventName.characters.count >= 4 && eventName.characters.count <= 140 {
            performSegue(withIdentifier: "BeginEditingNewEventDue", sender: self)
        } else if eventName.characters.count < 4 {
            errorLabel.text = "额，也太简短了吧😅"
            errorLabel.isHidden = false
        } else {
            errorLabel.text = "大家都说貌似140个字以内比较优秀☺"
            errorLabel.isHidden = false
        }
    }
    
    @IBAction func close() {
        self.textView.resignFirstResponder()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension NewEventNameViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if placeholderLabel.text != "" && !textView.text.isEmpty {
            placeholderLabel.text = ""
        }
        
        if textView.markedTextRange == nil {
            eventName = textView.text
        }
        
        errorLabel.isHidden = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            goNext()
            return false
        }
        return true
    }
}
