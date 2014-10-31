//
//  ComicOrSeriesVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/29/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class ComicOrSeriesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var comic: Comic?
    var series: Series?
    var fullUrl: String?
    var charactersInComicOrSeries = [Character]()
    var canLoadMore = true
    
    @IBOutlet var imageZoomView : ImageZoomView!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.title = comic != nil ? comic?.title : series?.title
        
        // register CharacterCell nib for the collection view
        let nib = UINib(nibName: "CharacterCell", bundle: NSBundle.mainBundle())
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "CHARACTER_CELL")

        var flowlayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        flowlayout.itemSize = CGSize(width: 110.0, height: 140.0)
        flowlayout.sectionInset = UIEdgeInsetsMake(5.0, 7.0, 0.0, 7.0)

        
        self.loadCharactersWithLimit(10, startIndex: self.charactersInComicOrSeries.count)

        
        if comic != nil {
            // display comic
            self.titleLabel.text = self.comic?.title
            if let thumb = self.comic?.thumbnailURL {
                self.fullUrl = "\(thumb.path).\(thumb.ext)"
            }
        } else {
            // display series
            self.titleLabel.text = self.series?.title
            if let thumb = self.series?.thumbnailURL {
                self.fullUrl = "\(thumb.path).\(thumb.ext)"
            }
        }

        MarvelCaching.caching.cachedImageForURLString(self.fullUrl!, completion: { (image) -> Void in
            if image != nil {
                self.imageZoomView.displayImage(image)
            }
            else {
                self.activityIndicator.startAnimating()
                MarvelNetworking.controller.getImageAtURLString(self.fullUrl!, completion: { (image, errorString) -> Void in
                    self.activityIndicator.stopAnimating()
                    if errorString != nil {
                        println(errorString)
                        return
                    }
                    
                    MarvelCaching.caching.setCachedImage(image!, forURLString: self.fullUrl!)
                    self.imageZoomView.displayImage(image)
                })
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        MarvelCaching.caching.clearMemoryCache()
    }
    
    func loadCharactersWithLimit(_ limit: Int? = nil, startIndex: Int? = nil) {
        if comic != nil {
            println(self.comic!.id)
            MarvelNetworking.controller.getCharactersWithComicID(self.comic!.id, startIndex: startIndex, limit: limit) { (errorString, charactersArray, itemsLeft) -> Void in
                self.processCharactersResponse(errorString: errorString, charactersArray: charactersArray, itemsLeft: itemsLeft)
            }
        } else {
            println(self.series!.id)
            MarvelNetworking.controller.getCharactersWithSeriesID(self.series!.id, startIndex: startIndex, limit: limit) { (errorString, charactersArray, itemsLeft) -> Void in
                self.processCharactersResponse(errorString: errorString, charactersArray: charactersArray, itemsLeft: itemsLeft)
            }
        }
    }

    private func processCharactersResponse(#errorString: String?, charactersArray: NSArray?, itemsLeft: Int?) {
        if charactersArray != nil {
            if itemsLeft? == 0 {
                self.canLoadMore = false
            }
            
            var newCharacters = Character.parseJSONIntoCharacters(data: charactersArray!)
            self.charactersInComicOrSeries += newCharacters
            self.collectionView.reloadData()
        } else {
            println("no data")
            println(errorString)
        }
        
        if charactersArray?.count == 0 {
            self.canLoadMore = false
        }
    }


    // MARK: COLLECTION VIEW
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.charactersInComicOrSeries.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("CHARACTER_CELL", forIndexPath: indexPath) as CharacterCell
        
        cell.imageView.image = nil
        
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let currentCharacter = self.charactersInComicOrSeries[indexPath.row]
        cell.nameLabel.text = currentCharacter.name
        println(currentCharacter.name)
        
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
        characterDetailVC.characterToDisplay = self.charactersInComicOrSeries[indexPath.row]
        self.navigationController?.pushViewController(characterDetailVC, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if !self.canLoadMore {
            return
        }
        
        var indexPathToLoadMoreCharacters = self.charactersInComicOrSeries.count
        if indexPath.row + 1 == indexPathToLoadMoreCharacters {
            self.loadCharactersWithLimit(10, startIndex: self.charactersInComicOrSeries.count)
        }
    }

    
    
    //    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        if self.header == nil {
//            self.header = self.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER", forIndexPath: indexPath) as? CollectionHeader
//            self.header?.searchBar.delegate = self
//        }
//        
//        return header
//    }
    
}

