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
        
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        self.webView.allowsBackForwardNavigationGestures = true
        
        var targetURL = "http://marvel.com/"
        if let detailURL = self.character?.detailURL {
            targetURL = detailURL
        }
        
        let url = NSURL(string: targetURL)!
        self.webView.loadRequest(NSURLRequest(URL: url))
        
    }

}
