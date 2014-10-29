//
//  ComicVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/29/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class ComicVC: UIViewController {

    var comic: Comic?
    @IBOutlet var comicImageView : UIImageView!
    @IBOutlet var comicTitleLabel : UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.comicTitleLabel.text = self.comic!.title
        
        if let thumb = self.comic?.thumbnailURL {
            let thumbURL = "\(thumb.path)/portrait_uncanny.\(thumb.ext)"
            println(thumbURL)
            if let image = MarvelCaching.caching.cachedImageForURLString(thumbURL) {
                self.comicImageView.image = image
            }
            else {
                self.activityIndicator.startAnimating()
                
                MarvelNetworking.controller.getImageAtURLString(thumbURL, completion: { (image, errorString) -> Void in
                    if errorString != nil {
                        println(errorString)
                        return
                    }
                    
                    MarvelCaching.caching.setCachedImage(image!, forURLString: thumbURL)
                    self.activityIndicator.stopAnimating()
                    self.comicImageView.image = image
                })
            }
        }

    }

}