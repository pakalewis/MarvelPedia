//
//  CharacterDetailVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/27/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class CharacterDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var tableView : UITableView!
    var characterToDisplay : Character?
    let tableViewHeaders = ["Character", "Comics", "Series"]
    var comicsForCharacter = [Comic]()
    var seriesForCharacter = [Series]()
    
    weak var comicsCollectionView: UICollectionView?
    weak var seriesCollectionView: UICollectionView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        

        // register the nibs for the two types of tableview cells
        let nib = UINib(nibName: "InfoCell", bundle: NSBundle.mainBundle())
        self.tableView.registerNib(nib, forCellReuseIdentifier: "INFO_CELL")
        
        let newNib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.registerNib(newNib, forCellReuseIdentifier: "CUSTOM_CELL")
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    // MARK: MAIN TABLEVIEW
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionHeaderLabel = UILabel()
        sectionHeaderLabel.text = self.tableViewHeaders[section]
        sectionHeaderLabel.font = UIFont(name: "AvenirNext-Bold", size: 25.0)
        sectionHeaderLabel.textAlignment = NSTextAlignment.Center
        sectionHeaderLabel.textColor = UIColor.blackColor()
        sectionHeaderLabel.backgroundColor = UIColor.grayColor()
        return sectionHeaderLabel
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.characterToDisplay?.bio == "" {
                return 1 // no bio to display
            }
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var screenHeight = UIScreen.mainScreen().bounds.height
        if indexPath.section != 0 {
            var customCellHeight = screenHeight / 3
            return customCellHeight
        } else {
            
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 1 { // in the comics section
            let cell = self.tableView.dequeueReusableCellWithIdentifier("CUSTOM_CELL") as CustomTableViewCell
            
            self.comicsCollectionView = cell.customCollectionView
            
            cell.customCollectionView.delegate = self
            cell.customCollectionView.dataSource = self
            cell.customCollectionView.backgroundColor = UIColor.lightGrayColor()
            MarvelNetworking.controller.getComicsWithCharacterID(self.characterToDisplay!.id, limit: 3, completion: { (errorString, comicsArray) -> Void in
                if comicsArray != nil {
                    self.comicsForCharacter = Comic.parseJSONIntoComics(data: comicsArray!)
                    cell.customCollectionView.reloadData()
                    
                } else {
                    println("no data")
                }
            })
            
            return cell
        }
        
        
        if indexPath.section == 2 { // in the series section
            let cell = self.tableView.dequeueReusableCellWithIdentifier("CUSTOM_CELL") as CustomTableViewCell
            
            self.seriesCollectionView = cell.customCollectionView
            
            cell.customCollectionView.delegate = self
            cell.customCollectionView.dataSource = self
            cell.customCollectionView.backgroundColor = UIColor.lightGrayColor()

            MarvelNetworking.controller.getSeriesWithCharacterID(self.characterToDisplay!.id, limit: 3, completion: { (errorString, seriesArray) -> Void in
                if seriesArray != nil {
                    self.seriesForCharacter = Series.parseJSONIntoSeries(data: seriesArray!)
                    cell.customCollectionView.reloadData()
                    
                } else {
                    println("no data")
                }
            })
            
            return cell
        }
        
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("INFO_CELL", forIndexPath: indexPath) as InfoCell
        if indexPath.row == 0 {
            cell.infoCellLabel.text = "\(self.characterToDisplay!.name)"
        } else {
            cell.infoCellLabel.text = "\(self.characterToDisplay!.bio)"
        }

        
        
        // modify the thumbnail url in order to download a larger version of the character's image
        if let thumb = self.characterToDisplay!.thumbnailURL {
            var urlForLargerImage = "\(thumb.path)/portrait_uncanny.\(thumb.ext)"
            MarvelNetworking.controller.getImageAtURLString(urlForLargerImage, completion: { (image, errorString) -> Void in
                // load the larger image into the header
            })
        }
        
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    
    
    
    
    // MARK: COLLECTION VIEW WITHIN A TABLEVIEW CELL
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.comicsCollectionView {
            println("num items in comics CV \(self.comicsForCharacter.count)")
            return self.comicsForCharacter.count
        }
        else {
            println("num items in series CV \(self.seriesForCharacter.count)")
            return self.seriesForCharacter.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // could change this to be creating different cells: ComicCell or SeriesCell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("COMIC_CELL", forIndexPath: indexPath) as ComicCell
        cell.backgroundColor = UIColor.grayColor()
        
        // determine the image url
        var sourceURL = ""
        if collectionView == self.comicsCollectionView {
            let currentComic = self.comicsForCharacter[indexPath.row]
            if let thumb = currentComic.thumbnailURL {
                sourceURL = "\(thumb.path)/standard_xlarge.\(thumb.ext)"
            }
        }
        else {
            let currentSeries = self.seriesForCharacter[indexPath.row]
            if let thumb = currentSeries.thumbnailURL {
                sourceURL = "\(thumb.path)/standard_xlarge.\(thumb.ext)"
            }
        }
        
        // either grab the image from the cache or download it
        MarvelCaching.caching.cachedImageForURLString(sourceURL, completion: { (image) -> Void in
            if image != nil {
                cell.comicImageView.image = image
            }
            else {
                cell.activityIndicator.startAnimating()
                MarvelNetworking.controller.getImageAtURLString(sourceURL, completion: { (image, errorString) -> Void in
                    if errorString != nil {
                        println(errorString)
                        return
                    }
                    MarvelCaching.caching.setCachedImage(image!, forURLString: sourceURL)
                    cell.activityIndicator.stopAnimating()
                    cell.comicImageView.image = image
                })
            }
        })
        
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.comicsCollectionView {
            println("comic selected at \(indexPath.row)")
            let comic = self.comicsForCharacter[indexPath.row] as Comic
            println(comic.title)
            var comicVC = storyboard?.instantiateViewControllerWithIdentifier("COMIC_VC") as ComicVC
            comicVC.comic = comic
            self.navigationController?.pushViewController(comicVC, animated: true)
            
        }
        else {
            println("series selected at \(indexPath.row)")
            let series = self.seriesForCharacter[indexPath.row] as Series
            println(series.title)
            var seriesVC = storyboard?.instantiateViewControllerWithIdentifier("SERIES_VC") as SeriesVC
            seriesVC.series = series
            self.navigationController?.pushViewController(seriesVC, animated: true)
            
        }

        

    }
    
    
    
    
    
    
}
