//
//  CardViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 4/11/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    var pageIndex: Int?
    var welcomeCard: WelcomeCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = welcomeCard.image
        button.isHidden = !welcomeCard.showButton
        button.layer.cornerRadius = button.bounds.height / 2.0
        button.backgroundColor = UIColor.buttonBlue
        button.addTarget(self, action: #selector(goSignUp), for: .touchUpInside)
    }
    
    func goSignUp() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}
