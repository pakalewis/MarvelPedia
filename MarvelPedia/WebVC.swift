//
//  WebVC.swift
//  MarvelPedia
//
//  Created by Casey R White on 10/29/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController, WKNavigationDelegate {

    let webView = WKWebView()
    let indicatorView = UIActivityIndicatorView()
    var character: Character?
    
    override func loadView() {
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        self.webView.allowsBackForwardNavigationGestures = true
        
        self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.indicatorView.hidesWhenStopped = true
        
        let transform = CGAffineTransformMakeScale(4.0, 4.0);
        self.indicatorView.transform = transform;
        
        self.indicatorView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin |
            UIViewAutoresizing.FlexibleRightMargin |
            UIViewAutoresizing.FlexibleTopMargin |
            UIViewAutoresizing.FlexibleBottomMargin
        
        self.webView.addSubview(self.indicatorView)
        
        var targetURL = "http://marvel.com/"
        if let detailURL = self.character?.detailURL {
            targetURL = detailURL
        }
        
        let url = NSURL(string: targetURL)!
        self.webView.loadRequest(NSURLRequest(URL: url))
        
        self.webView.navigationDelegate = self
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.indicatorView.startAnimating()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.indicatorView.stopAnimating()
    }
}
