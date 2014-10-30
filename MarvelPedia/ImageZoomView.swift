//
//  ImageZoomView.swift
//  MarvelPedia
//
//  Created by Alex G on 30.10.14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

let kImageZoomViewAutomaticTolerance: CGFloat = 0.1
let kImageZoomViewZoomTolerance: CGFloat = 0.01

class ImageZoomView: UIScrollView, UIScrollViewDelegate {

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
    
    func handleDoubleTap(gestureRecognizer: UIGestureRecognizer)
    {
        if (self.maximumZoomScale > self.minimumZoomScale) {
            if (self.zoomScale <= self.minimumZoomScale + CGFloat(FLT_EPSILON)) {
                let point = gestureRecognizer.locationInView(displayView)
                let zoomRect = CGRectMake(point.x - 1, point.y - 1, 2, 2)
                self.zoomToRect(zoomRect, animated: true)
            }
            else
            {
                let atOrigin = CGPointEqualToPoint(self.contentOffset, CGPointZero) // Work around a strange behavior where if zooming out while changing contentInset from zero to non-zero at the same time
                if (atOrigin) {
                    self.contentOffset = CGPointMake(1, 1)
                }
                
                self.setZoomScale(self.minimumZoomScale, animated: true)
            
                if (atOrigin) {
                    self.contentOffset = CGPointMake(0, 0)
                }
            }
        }
    }
    
    private func initialize() {
        self.alwaysBounceHorizontal = false
        self.alwaysBounceVertical = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.bouncesZoom = true
        self.clipsToBounds = true
        self.scrollsToTop = false
        self.autoresizesSubviews = false
        self.delegate = self
        
        self.contentMode = UIViewContentMode.ScaleAspectFit
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapRecognizer)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update layout if we have a display view
        if displayView != nil {
            var boundsSize = self.bounds.size
            
            // Check if zoom values need to be recomputed
            if (!CGSizeEqualToSize(boundsSize, oldSize)) {
                // Save current zoom factor
                var oldZoomFactor: CGFloat = 0.0
                if (self.maximumZoomScale > self.minimumZoomScale) {
                    oldZoomFactor = (self.zoomScale - self.minimumZoomScale) / (self.maximumZoomScale - self.minimumZoomScale)
                }
                
                // Compute new min and max zoom
                let fitZoomScale = min(boundsSize.width / displaySize.width, boundsSize.height / displaySize.height)
                let fillZoomScale = max(boundsSize.width / displaySize.width, boundsSize.height / displaySize.height)
                let ratio = (displaySize.width / displaySize.height) / (boundsSize.width / boundsSize.height)
                if ((ratio >= 1 - kImageZoomViewAutomaticTolerance) && (ratio <= 1 + kImageZoomViewAutomaticTolerance)) {
                    self.minimumZoomScale = fillZoomScale
                }
                else {
                    self.minimumZoomScale = fitZoomScale
                }
                
                let maxZoomScale = max(boundsSize.width, boundsSize.height) / min(displaySize.width, displaySize.height)
                self.maximumZoomScale = maxZoomScale
                
                // Update current zoom
                if (CGSizeEqualToSize(oldSize, CGSizeZero)) {
                    self.zoomScale = 1 // Be extra safe by resetting zoom scale before setting content size
                    self.contentSize = displaySize
                    self.zoomScale = self.minimumZoomScale
                }
                else
                {
                    if (oldZoomFactor <= kImageZoomViewZoomTolerance) {
                        self.zoomScale = self.minimumZoomScale
                    }
                    else if (oldZoomFactor >= 1 - kImageZoomViewZoomTolerance) {
                        self.zoomScale = self.maximumZoomScale
                    }
                    else {
                        self.zoomScale = min(max(self.zoomScale, self.minimumZoomScale), self.maximumZoomScale)
                    }
                }
                
                oldSize = boundsSize
            }
            
            // Update padding around display view if necessary
            let contentSize = self.contentSize // Content size depends on current zoom scale
            let paddingX = max((boundsSize.width - contentSize.width) / 2, 0)
            let paddingY = max((boundsSize.height - contentSize.height) / 2, 0)
            let edgeInsets = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX)
            if (!UIEdgeInsetsEqualToEdgeInsets(edgeInsets, self.contentInset)) {
                self.contentInset = edgeInsets
            }
        }
        else // Otherwise reset everything
        {
            self.contentInset = UIEdgeInsetsZero
            self.contentOffset = CGPointZero
            self.minimumZoomScale = 1
            self.maximumZoomScale = 1
            self.zoomScale = 1
        }

    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return displayView
    }

}
