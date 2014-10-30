//
//  HomeVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/27/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UINavigationControllerDelegate, UISearchBarDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var characters = [Character]()
    var header : UICollectionReusableView!
    var canLoadMore = true
    var searchBarText = ""
    var selectedScope = 0
    
    var characterCollectionDelegate: CharacterCollectionDelegate?
    var comicCollectionDelegate: ComicCollectionDelegate?
    
    override func viewDidLoad() {
        self.characterCollectionDelegate = CharacterCollectionDelegate(viewController: self)
        self.comicCollectionDelegate = ComicCollectionDelegate(viewController: self)
        
        self.collectionView.delegate = self.characterCollectionDelegate!
        self.collectionView.dataSource = self.characterCollectionDelegate!
        self.navigationController?.delegate = self
        
        // register CharacterCell nib for the collection view
        let nib = UINib(nibName: "CharacterCell", bundle: NSBundle.mainBundle())
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "CHARACTER_CELL")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        MarvelCaching.caching.clearMemoryCache()
    }
    
    // MARK: Private Methods
    
    func loadCharactersWithLimit(_ limit: Int? = nil, startIndex: Int? = nil) {
        self.activityIndicator.startAnimating()
        MarvelNetworking.controller.getCharacters(nameQuery: self.searchBarText, limit: limit, startIndex: startIndex, completion: { (errorString, charactersArray, itemsLeft) -> Void in
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
    
    // MARK: SEARCH BAR
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("searching for \(searchBar.text)")
        self.canLoadMore = true
        self.characters = [Character]()
        self.collectionView.reloadData()
        
        // save the searchBar text as a local variable
        self.searchBarText = searchBar.text
        
        loadCharactersWithLimit(20)
    }
    
}
