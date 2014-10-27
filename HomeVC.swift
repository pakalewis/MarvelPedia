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
        
        MarvelNetworking.controller.getCharacters(nameQuery: "Spiasdfadsfasdfder") { (errorString, charactersArray) -> Void in
            
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
        
        let currentCharacter = self.characters[indexPath.row]
        
        MarvelNetworking.controller.performRequestWithURLString(currentCharacter.thumbnailURL, method:"GET", parameters: nil, acceptJSONResponse: true, sendBodyAsJSON: false, completion: {(data, errorString) -> Void in
            
            cell.imageView.image = UIImage(data: data)
        
        })
        //cell.imageView.image = currentCharacter.
//        cell.imageView.backgroundColor = UIColor.yellowColor()
        cell.nameLabel.text = "NAME"
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var characterDetailVC = storyboard?.instantiateViewControllerWithIdentifier("CHARACTER_DETAIL_VC") as CharacterDetailVC
        
        self.navigationController?.pushViewController(characterDetailVC, animated: true)
    }

}
