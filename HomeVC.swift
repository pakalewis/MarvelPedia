//
//  HomeVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/27/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    var characters = [Character]()

    
    override func viewDidLoad() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.navigationController?.delegate = self
        
        // register CharacterCell nib for the collection view
        let nib = UINib(nibName: "CharacterCell", bundle: NSBundle.mainBundle())
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "CHARACTER_CELL")
        
        MarvelNetworking.controller.getCharacters(nameQuery: "S") { (errorString, charactersArray) -> Void in
            
            if charactersArray != nil {
                self.characters = Character.parseJSONIntoCharacters(data: charactersArray!)
            } else {
                println("no data")
            }
            self.collectionView.reloadData()
        }
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

        if currentCharacter.thumbnailURL != nil {
            MarvelNetworking.controller.getImageAtURLString(currentCharacter.thumbnailURL!, completion: { (image, errorString) -> Void in
                
                if cell.tag == currentTag {
                    cell.imageView.image = image
                }
            })
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var characterDetailVC = storyboard?.instantiateViewControllerWithIdentifier("CHARACTER_DETAIL_VC") as CharacterDetailVC
        
        self.navigationController?.pushViewController(characterDetailVC, animated: true)
    }

}
