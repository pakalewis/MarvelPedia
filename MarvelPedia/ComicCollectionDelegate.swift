//
//  ComicCollectionDelegate.swift
//  MarvelPedia
//
//  Created by Casey R White on 10/30/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class ComicCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    weak var viewController: HomeVC? = nil
    
    init(viewController: UIViewController) {
        self.viewController = viewController as? HomeVC
    }
    // MARK: COLLECTION VIEW
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
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let characterDetailVC = storyboard.instantiateViewControllerWithIdentifier("CHARACTER_DETAIL_VC") as CharacterDetailVC
        characterDetailVC.characterToDisplay = self.viewController!.characters[indexPath.row]
        self.viewController!.navigationController?.pushViewController(characterDetailVC, animated: true)
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if self.viewController!.header == nil {
            self.viewController!.header = self.viewController!.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER", forIndexPath: indexPath) as UICollectionReusableView
            let headerFrame = self.viewController!.header.frame
            var searchBar = UISearchBar(frame: headerFrame)
            searchBar.showsScopeBar = true
            searchBar.scopeButtonTitles = ["Characters", "Comics"]
            self.viewController!.header.addSubview(searchBar)
            
            searchBar.delegate = self.viewController!
        }
        
        return self.viewController!.header
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if !self.viewController!.canLoadMore {
            return
        }
        
        var indexPathToLoadMoreCharacters = self.viewController!.characters.count
        if indexPath.row + 1 == indexPathToLoadMoreCharacters {
            self.viewController!.loadCharactersWithLimit(40, startIndex: self.viewController!.characters.count)
        }
    }
    
}
