//
//  NicknameViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 8/26/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class NicknameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameView: UIView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var nickname: String {
        get {
            return (nicknameTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        set {
            nicknameTextField.text = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.backgroundGray
        
        nicknameTextField.delegate = self
        errorLabel.isHidden = true
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            containerView.transform = CGAffineTransform(translationX: 0,y: -80)
        }
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            nicknameTextField.placeholder = "该叫什么呢"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        nicknameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !nickname.isEmpty() {
            User.nickname = nickname
            errorLabel.isHidden = true
            nicknameTextField.resignFirstResponder()
            performSegue(withIdentifier: "go to password", sender: self)
        } else {
            errorLabel.isHidden = false
        }
        return true
    }
}
