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
    let tableViewHeaders = ["", "Comics", "Series"]
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
        
        let newNib = UINib(nibName: "TVCellWithCollectionView", bundle: nil)
        self.tableView.registerNib(newNib, forCellReuseIdentifier: "TVCELL")
        
        

    }
    
    
    // MARK: MAIN TABLEVIEW
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionHeaderLabel = UILabel()
        sectionHeaderLabel.text = self.tableViewHeaders[section]
        sectionHeaderLabel.font = UIFont(name: "Arial", size: 22.0)
        sectionHeaderLabel.textAlignment = NSTextAlignment.Center
        sectionHeaderLabel.textColor = UIColor.blueColor()
        sectionHeaderLabel.backgroundColor = UIColor.lightGrayColor()
        return sectionHeaderLabel
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section != 0 {
            return 80.0
        } else {
            return 30.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 1 { // in the comics section
            let cell = self.tableView.dequeueReusableCellWithIdentifier("TVCELL") as TVCellWithCollectionView
            
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
            let cell = self.tableView.dequeueReusableCellWithIdentifier("TVCELL") as TVCellWithCollectionView
            
            self.seriesCollectionView = cell.customCollectionView
            
            cell.customCollectionView.delegate = self
            cell.customCollectionView.dataSource = self
            cell.customCollectionView.backgroundColor = UIColor.lightGrayColor()

            MarvelNetworking.controller.getSeriesWithCharacterID(self.characterToDisplay!.id, limit: 2, completion: { (errorString, seriesArray) -> Void in
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
            cell.textLabel.text = "Name: \(self.characterToDisplay!.name)"
        } else {
            cell.textLabel.text = "Bio: \(self.characterToDisplay!.bio)"
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("COMIC_CELL", forIndexPath: indexPath) as ComicCell
        
        // pull the comic from the comicsForCharacter array and grab it's name and image
        let currentComic = self.comicsForCharacter[indexPath.row]
        if let thumb = currentComic.thumbnailURL {
            let thumbURL = "\(thumb.path)/standard_xlarge.\(thumb.ext)"
            
            if let image = MarvelCaching.caching.cachedImageForURLString(thumbURL) {
                cell.comicImageView.image = image
            }
            else {
                MarvelNetworking.controller.getImageAtURLString(thumbURL, completion: { (image, errorString) -> Void in
                    if errorString != nil {
                        println(errorString)
                        return
                    }
                    
                    MarvelCaching.caching.setCachedImage(image!, forURLString: thumbURL)
                        cell.comicImageView.image = image
                })
            }
        }
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("comic selected at \(indexPath.row)")
        let comic = self.comicsForCharacter[indexPath.row] as Comic
        println(comic.title)
        

        var comicVC = storyboard?.instantiateViewControllerWithIdentifier("COMIC_VC") as ComicVC
        comicVC.comic = comic
        self.navigationController?.pushViewController(comicVC, animated: true)
    }
    
    
    
    
    
    
}
