//
//  HomeVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/27/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UISearchBarDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var characters = [Character]()
    var header : CollectionHeader!
    var canLoadMore = true

    
    override func viewDidLoad() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.navigationController?.delegate = self
        
        // register CharacterCell nib for the collection view
        let nib = UINib(nibName: "CharacterCell", bundle: NSBundle.mainBundle())
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "CHARACTER_CELL")
        
        //self.activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: Private Methods
    
    func loadCharactersWithLimit(_ limit: Int? = nil, startIndex: Int? = nil) {
        self.activityIndicator.startAnimating()
        MarvelNetworking.controller.getCharacters(nameQuery: self.header.searchBar.text, limit: limit, startIndex: startIndex, completion: { (errorString, charactersArray, itemsLeft) -> Void in
            if charactersArray != nil {
                if itemsLeft? == 0 {
                    self.canLoadMore = false
                }
                
                var newCharacters = Character.parseJSONIntoCharacters(data: charactersArray!)
                self.characters += newCharacters
                self.collectionView.reloadData()
            } else {
                println("no data")
                println(errorString)
            }
            
            if charactersArray?.count == 0 {
                self.canLoadMore = false
            }
            self.activityIndicator.stopAnimating()
        })
    }
    
    // MARK: COLLECTION VIEW
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.characters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("CHARACTER_CELL", forIndexPath: indexPath) as CharacterCell

        cell.imageView.image = nil
        
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let currentCharacter = self.characters[indexPath.row]
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
        var characterDetailVC = storyboard?.instantiateViewControllerWithIdentifier("CHARACTER_DETAIL_VC") as CharacterDetailVC
        characterDetailVC.characterToDisplay = self.characters[indexPath.row]
        self.navigationController?.pushViewController(characterDetailVC, animated: true)
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if self.header == nil {
            self.header = self.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER", forIndexPath: indexPath) as? CollectionHeader
            self.header?.searchBar.delegate = self
        }
        
        return header
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if !self.canLoadMore {
            return
        }
        
        var indexPathToLoadMoreCharacters = self.characters.count
        if indexPath.row + 1 == indexPathToLoadMoreCharacters {
            loadCharactersWithLimit(40, startIndex: self.characters.count)
        }
    }
    
    // MARK: SEARCH BAR
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("searching for \(searchBar.text)")
        self.canLoadMore = true
        self.characters = [Character]()
        self.collectionView.reloadData()
        
        loadCharactersWithLimit(20)
    }
    
}
