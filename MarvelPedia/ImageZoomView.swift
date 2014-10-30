//
//  ImageZoomView.swift
//  MarvelPedia
//
//  Created by Alex G on 30.10.14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class ImageZoomView: UIScrollView {

    private var oldSize: CGSize!
    private var displaySize: CGSize!
    private var displayView: UIView?
    private var imageView: UIImageView!
    private var image: UIImage!
    
    func displayImage(image: UIImage!) {
        if image == nil {
            return
        }
        
        if (self.image != nil) && self.image.isEqual(image) {
            return
        }
        
        self.image = image
        
        // Replace display view
        displayView?.removeFromSuperview()
        displayView = UIImageView(image: image)
        
        if displayView != nil {
            self.addSubview(displayView!)
            displaySize = displayView!.frame.size
        }
        else {
            displaySize = CGSizeZero
        }
        
        // Force a layout
        oldSize = CGSizeZero
        self.setNeedsLayout()
    }

}
