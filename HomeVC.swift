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

    
    override func viewDidLoad() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.navigationController?.delegate = self
        
        // register CharacterCell nib for the collection view
        let nib = UINib(nibName: "CharacterCell", bundle: NSBundle.mainBundle())
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "CHARACTER_CELL")
        
        self.activityIndicator.hidesWhenStopped = true
    }
    
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
            
            if let image = MarvelCaching.caching.cachedImageForURLString(thumbURL) {
                cell.imageView.image = image
            }
            else {
                cell.activityIndicator.startAnimating()
                
                MarvelNetworking.controller.getImageAtURLString(thumbURL, completion: { (image, errorString) -> Void in
                    if errorString != nil {
                        println(errorString)
                        return
                    }
                    
                    MarvelCaching.caching.setChachedImage(image!, forURLString: thumbURL)
                    if cell.tag == currentTag {
                        cell.activityIndicator.stopAnimating()
                        cell.imageView.image = image
                    }
                })
            }
        }
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var characterDetailVC = storyboard?.instantiateViewControllerWithIdentifier("CHARACTER_DETAIL_VC") as CharacterDetailVC
        characterDetailVC.characterToDisplay = self.characters[indexPath.row]
        self.navigationController?.pushViewController(characterDetailVC, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = self.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER", forIndexPath: indexPath) as CollectionHeader
        
        header.searchBar.delegate = self
        
        return header
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("searching for \(searchBar.text)")
        self.characters = [Character]()
        self.collectionView.reloadData()
        self.activityIndicator.startAnimating()
        
        MarvelNetworking.controller.getCharacters(nameQuery: searchBar.text, completion: { (errorString, charactersArray) -> Void in
            
            if charactersArray != nil {
                self.characters = Character.parseJSONIntoCharacters(data: charactersArray!)
            } else {
                println("no data")
            }
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        })
    }
    
}
