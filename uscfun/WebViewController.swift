//
//  WebViewController.swift
//  uscfun
//
//  Created by Wenzheng Li on 10/14/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var url: URL?
    var webTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = webTitle
        self.webView.delegate = self
        if let url = url {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        } else {
            print("url is nil")
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("did start load web")
        self.indicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("did finish load web")
        self.indicatorView.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("did finish load web with error")
        self.indicatorView.stopAnimating()
    }
}
