//
//  SeriesVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/29/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class SeriesVC: UIViewController {

    var series: Series?
    @IBOutlet var seriesImageView : UIImageView!
    @IBOutlet var seriesTitleLabel : UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.seriesTitleLabel.text = self.series?.title
        
        
        if let thumb = self.series?.thumbnailURL {
            let thumbURL = "\(thumb.path)/portrait_uncanny.\(thumb.ext)"
            
            MarvelCaching.caching.cachedImageForURLString(thumbURL, completion: { (image) -> Void in
                if image != nil {
                    self.seriesImageView.image = image
                }
                else {
                    MarvelNetworking.controller.getImageAtURLString(thumbURL, completion: { (image, errorString) -> Void in
                        if errorString != nil {
                            println(errorString)
                            return
                        }
                        
                        MarvelCaching.caching.setCachedImage(image!, forURLString: thumbURL)
                        self.seriesImageView.image = image
                    })
                }
            })
            
        }
    }
}
    
//        if let thumb = self.series?.thumbnailURL {
//            let thumbURL = "\(thumb.path)/portrait_uncanny.\(thumb.ext)"
//            println(thumbURL)
//            if let image = MarvelCaching.caching.cachedImageForURLString(thumbURL) {
//                self.seriesImageView.image = image
//            }
//            else {
//                self.activityIndicator.startAnimating()
//                
//                MarvelNetworking.controller.getImageAtURLString(thumbURL, completion: { (image, errorString) -> Void in
//                    if errorString != nil {
//                        println(errorString)
//                        return
//                    }
//                    
//                    MarvelCaching.caching.setCachedImage(image!, forURLString: thumbURL)
//                    self.activityIndicator.stopAnimating()
//                    self.seriesImageView.image = image
//                })
//            }
//        }
//        
//    }

