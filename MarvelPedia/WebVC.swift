//
//  WebVC.swift
//  MarvelPedia
//
//  Created by Casey R White on 10/29/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController {

    let webView = WKWebView()
    var character: Character?
    
    override func loadView() {
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = self.webView
        
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        self.webView.allowsBackForwardNavigationGestures = true
        
        let spidermanURL = "http://marvel.com/characters/54/spider-man"
        let url = NSURL(string: spidermanURL)!
        self.webView.loadRequest(NSURLRequest(URL: url))
        
    }

}
