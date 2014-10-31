//
//  ComicCollectionDelegate.swift
//  MarvelPedia
//
//  Created by Casey R White on 10/30/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class ComicCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    weak var viewController: HomeVC! = nil
    
    init(viewController: UIViewController) {
        self.viewController = viewController as? HomeVC
    }
    // MARK: COLLECTION VIEW
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        return viewController.headerView()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewController!.characters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.viewController!.collectionView.dequeueReusableCellWithReuseIdentifier("CHARACTER_CELL", forIndexPath: indexPath) as CharacterCell
        
        cell.imageView.image = nil
        
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let currentCharacter = self.viewController!.characters[indexPath.row]
        cell.nameLabel.text = currentCharacter.name
        
        if let thumb = currentCharacter.thumbnailURL {
            let thumbURL = "\(thumb.path)/standard_xlarge.\(thumb.ext)"
            
            
            MarvelCaching.caching.cachedImageForURLString(thumbURL, completion: { (image) -> Void in
                if image != nil {
                    if cell.tag == currentTag {
                        cell.imageView.image = nil
                        cell.imageView.image = image
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
                        cell.imageView.image = nil
                        UIView.transitionWithView(cell.imageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                            cell.imageView.image = image
                            }, completion: nil)
                    }
                })
                
            })
        }
        else {
            cell.imageView.image = UIImage(named: "notfound_image200x200.jpg")
        }
        
        return cell
    }
}
