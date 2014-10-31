//
//  CollectionDelegateComic.swift
//  MarvelPedia
//
//  Created by Casey R White on 10/30/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class CollectionDelegateComic: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    weak var viewController: HomeVC! = nil
    
    init(viewController: UIViewController) {
        self.viewController = viewController as? HomeVC
    }
    // MARK: COLLECTION VIEW
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        return viewController.headerView()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewController!.comics.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.viewController!.collectionView.dequeueReusableCellWithReuseIdentifier("COMIC_CELL", forIndexPath: indexPath) as ComicCell
        
        cell.comicImageView.image = nil
        
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let currentComic = self.viewController!.comics[indexPath.row]
        cell.comicTitleLabel.text = currentComic.title
        
        if let thumb = currentComic.thumbnailURL {
            let thumbURL = "\(thumb.path)/standard_xlarge.\(thumb.ext)"
            
            
            MarvelCaching.caching.cachedImageForURLString(thumbURL, completion: { (image) -> Void in
                if image != nil {
                    if cell.tag == currentTag {
                        cell.comicImageView.image = nil
                        cell.comicImageView.image = image
                    }
                    return
                }
                
                cell.activityIndicator.startAnimating()
                
                MarvelNetworking.controller.getImageAtURLString(thumbURL, completion: { (image, errorString) -> Void in
                    cell.activityIndicator.stopAnimating()
                    if errorString != nil {
                        println(errorString)
                        return
                    }
                    
                    MarvelCaching.caching.setCachedImage(image!, forURLString: thumbURL)
                    if cell.tag == currentTag {
                        cell.comicImageView.image = nil
                        UIView.transitionWithView(cell.comicImageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                            cell.comicImageView.image = image
                            }, completion: nil)
                    }
                })
                
            })
        }
        else {
            cell.comicImageView.image = UIImage(named: "notfound_image200x200.jpg")
        }
        
        return cell
    }
}
