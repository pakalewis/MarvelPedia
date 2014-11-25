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
    var comics = [Comic]()
    
    private var header: UICollectionReusableView!
    
    private var lastSearchTextCharacter = ""
    private var lastSearchTextComic = ""
    private var canLoadMoreCharacters = true
    private var canLoadMoreComics = true
    
    private var collectionDelegateCharacter: CollectionDelegateCharacter!
    private var collectionDelegateComic: CollectionDelegateComic!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionDelegateCharacter = CollectionDelegateCharacter(viewController: self)
        self.collectionDelegateComic = CollectionDelegateComic(viewController: self)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self.collectionDelegateCharacter
        self.navigationController?.delegate = self
        
        // register CharacterCell nib for the collection view
        self.collectionView.registerNib(UINib(nibName: "CharacterCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "CHARACTER_CELL")
        self.collectionView.registerNib(UINib(nibName: "ComicCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "COMIC_CELL")
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
            searchBar.autoresizingMask = .FlexibleWidth
            searchBar.showsScopeBar = true
            searchBar.scopeButtonTitles = ["Characters", "Comics"]
            searchBar.delegate = self
            searchBar.placeholder = "Character name starts with..."
            searchBar.barTintColor = UIColor.colorFromRGB(0xABD1CF)
            searchBar.tintColor = UIColor.colorFromRGB(0x2d3736)
            self.header.addSubview(searchBar)
        }
        
        return self.header
    }
    
    // MARK: Private Methods
    
    func loadCharactersWithLimit(_ limit: Int? = nil, startIndex: Int? = nil) {
        MarvelNetworking.controller.getCharacters(nameQuery: searchBar.text, limit: limit, startIndex: startIndex, completion: { (errorString, charactersArray, itemsLeft) -> Void in
            if charactersArray != nil {
                if itemsLeft? == 0 {
                    self.canLoadMoreCharacters = false
                }
                
                var newCharacters = Character.parseJSONIntoCharacters(data: charactersArray!)
                self.characters += newCharacters
                self.collectionView.reloadData()
            } else {
                println("no data")
                println(errorString)
            }
            
            if charactersArray?.count == 0 {
                self.canLoadMoreCharacters = false
            }
            self.navigationItem.rightBarButtonItem = nil
            self.activityIndicator.stopAnimating()
        })
    }
    
    func loadComicsWithLimit(_ limit: Int? = nil, startIndex: Int? = nil) {
        MarvelNetworking.controller.getComics(titleQuery: searchBar.text, limit: limit, startIndex: startIndex, completion: { (errorString, comicsArray, itemsLeft) -> Void in
            if comicsArray != nil {
                if itemsLeft? == 0 {
                    self.canLoadMoreCharacters = false
                }
                
                var newComics = Comic.parseJSONIntoComics(data: comicsArray!)
                self.comics += newComics
                self.collectionView.reloadData()
            } else {
                println("no data")
                println(errorString)
            }
            
            if comicsArray?.count == 0 {
                self.canLoadMoreComics = false
            }
            self.navigationItem.rightBarButtonItem = nil
            self.activityIndicator.stopAnimating()
        })
    }
    
    // MARK: UICollectionViewDelegate Methods
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if searchBar.selectedScopeButtonIndex == 0 {
            let characterDetailVC = storyboard.instantiateViewControllerWithIdentifier("CHARACTER_DETAIL_VC") as CharacterDetailVC
            characterDetailVC.characterToDisplay = self.characters[indexPath.row]
            self.navigationController?.pushViewController(characterDetailVC, animated: true)
        } else {
            let comicVC = storyboard.instantiateViewControllerWithIdentifier("COMIC_OR_SERIES_VC") as ComicOrSeriesVC
            comicVC.comic = self.comics[indexPath.row]
            self.navigationController?.pushViewController(comicVC, animated: true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if (searchBar.selectedScopeButtonIndex == 0) {
            if !self.canLoadMoreCharacters {
                return
            }
            
            if indexPath.row + 1 == self.characters.count {
                loadCharactersWithLimit(40, startIndex: self.characters.count)
            }
        }
        else {
            if !self.canLoadMoreComics {
                return
            }
            
            if indexPath.row + 1 == self.comics.count {
                loadComicsWithLimit(40, startIndex: self.comics.count)
            }
        }
    }

    
    // MARK: SEARCH BAR
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("searching for \(searchBar.text)")

        // Only start activity indicator when search bar button clicked
        self.activityIndicator.startAnimating()
        
        
        // add Cancel button to the nav bar while searching
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonPressed:")
        self.navigationItem.rightBarButtonItem = cancelButton
        
        
        if searchBar.selectedScopeButtonIndex == 0 {
            self.canLoadMoreCharacters = true
            self.characters = [Character]()
            self.collectionView.reloadData()
            loadCharactersWithLimit(20)
        } else {
            self.canLoadMoreComics = true
            self.comics = [Comic]()
            self.collectionView.reloadData()
            loadComicsWithLimit(20)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.selectedScopeButtonIndex == 0 {
            lastSearchTextCharacter = searchText
        } else {
            lastSearchTextComic = searchText
        }
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if searchBar.selectedScopeButtonIndex == 1 {
            let flowlayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
            if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
                flowlayout.itemSize = CGSize(width: 150, height: 225 + 40)
            } else {
                flowlayout.itemSize = CGSize(width: 100, height: 150 + 40)
            }
        } else {
            let flowlayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
            flowlayout.itemSize = CGSize(width: 110.0, height: 140.0)
        }
        
        let charactersSearch = searchBar.selectedScopeButtonIndex == 0

        searchBar.text = charactersSearch ? lastSearchTextCharacter : lastSearchTextComic
        searchBar.placeholder = charactersSearch ? "Character name starts with..." : "Comic title starts with..."
        collectionView.dataSource = charactersSearch ? collectionDelegateCharacter : collectionDelegateComic
        collectionView.reloadData()
    }
    
    
    
    
    func cancelButtonPressed(sender : AnyObject?) {

    // Cancel the network call
    
    }
    
    
    
}
