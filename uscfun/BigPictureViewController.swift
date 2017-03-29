//
//  BigPictureViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 3/20/17.
//  Copyright © 2017 Wenzheng Li. All rights reserved.
//

import UIKit

class BigPictureViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        imageView.backgroundColor = UIColor.black
        imageView.image = image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(withdraw(sender:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func withdraw(sender: UITapGestureRecognizer) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
