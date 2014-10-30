//
//  ComicOrSeriesVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/29/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class ComicOrSeriesVC: UIViewController {

    var comic: Comic?
    var series: Series?
    var fullUrl: String?
    
    @IBOutlet var imageView : UIImageView!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if comic != nil {
            // display comic
            self.titleLabel.text = self.comic?.title
            if let thumb = self.comic?.thumbnailURL {
                self.fullUrl = "\(thumb.path).\(thumb.ext)"
            }
        } else {
            // display series
            self.titleLabel.text = self.series?.title
            if let thumb = self.series?.thumbnailURL {
                self.fullUrl = "\(thumb.path).\(thumb.ext)"
            }
        }

        MarvelCaching.caching.cachedImageForURLString(self.fullUrl!, completion: { (image) -> Void in
            if image != nil {
                self.imageView.image = image
            }
            else {
                MarvelNetworking.controller.getImageAtURLString(self.fullUrl!, completion: { (image, errorString) -> Void in
                    if errorString != nil {
                        println(errorString)
                        return
                    }
                    
                    MarvelCaching.caching.setCachedImage(image!, forURLString: self.fullUrl!)
                    self.imageView.image = image
                })
            }
        })
            
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        MarvelCaching.caching.clearMemoryCache()
    }
}

