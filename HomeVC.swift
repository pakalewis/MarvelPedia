//
//  HomeVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/27/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UINavigationControllerDelegate, UISearchBarDelegate, UICollectionViewDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var searchBar: UISearchBar!
    
    var characters = [Character]()
    
    private var header: UICollectionReusableView!
    private var canLoadMore = true
    
    private var lastSearchTextCharacter = ""
    private var lastSearchTextComic = ""
    
    private var collectionDelegateCharacter: CollectionDelegateCharacter!
    private var collectionDelegateComic: CollectionDelegateComic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionDelegateCharacter = CollectionDelegateCharacter(viewController: self)
        self.collectionDelegateComic = CollectionDelegateComic(viewController: self)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self.collectionDelegateCharacter
        self.navigationController?.delegate = self
        
        // register CharacterCell nib for the collection view
        let nib = UINib(nibName: "CharacterCell", bundle: NSBundle.mainBundle())
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "CHARACTER_CELL")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        MarvelCaching.caching.clearMemoryCache()
    }
    
    // MARK: Public Methods
    func headerView() -> UICollectionReusableView {
        if self.header == nil {
            self.header = self.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER", forIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as UICollectionReusableView
            let headerFrame = self.header.frame
            searchBar = UISearchBar(frame: headerFrame)
            searchBar.showsScopeBar = true
            searchBar.scopeButtonTitles = ["Characters", "Comics"]
            self.header.addSubview(searchBar)
            
            searchBar.delegate = self
        }
        
        return self.header
    }
    
    // MARK: Private Methods
    
    func loadCharactersWithLimit(_ limit: Int? = nil, startIndex: Int? = nil) {
        self.activityIndicator.startAnimating()
        MarvelNetworking.controller.getCharacters(nameQuery: searchBar.text, limit: limit, startIndex: startIndex, completion: { (errorString, charactersArray, itemsLeft) -> Void in
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
    
    // MARK: UICollectionViewDelegate Methods
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let characterDetailVC = storyboard.instantiateViewControllerWithIdentifier("CHARACTER_DETAIL_VC") as CharacterDetailVC
        characterDetailVC.characterToDisplay = self.characters[indexPath.row]
        self.navigationController?.pushViewController(characterDetailVC, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if !self.canLoadMore {
            return
        }
        
        var indexPathToLoadMoreCharacters = self.characters.count
        if indexPath.row + 1 == indexPathToLoadMoreCharacters {
            self.loadCharactersWithLimit(40, startIndex: self.characters.count)
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
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.selectedScopeButtonIndex == 0 {
            lastSearchTextCharacter = searchText
        }
        else {
            lastSearchTextComic = searchText
        }
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchBar.text = searchBar.selectedScopeButtonIndex == 0 ? lastSearchTextCharacter : lastSearchTextComic
        collectionView.dataSource = searchBar.selectedScopeButtonIndex == 0 ? collectionDelegateCharacter : collectionDelegateComic
        collectionView.reloadData()
    }
    
    
}
