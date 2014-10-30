//
//  CharacterDetailVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/27/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class CharacterDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    @IBOutlet var tableView : UITableView!
    var characterToDisplay : Character?
    let tableViewHeaders = ["Character", "Comics", "Series"]
    var comicsForCharacter = [Comic]()
    var seriesForCharacter = [Series]()
    
    weak var comicsCollectionView: UICollectionView?
    weak var seriesCollectionView: UICollectionView?
    var headerImageView: UIImageView!
    var headerActivityIndicator: UIActivityIndicatorView!
    let kDefaultHeaderImageYOffset: CGFloat = -64
    var headerImageYOffset: CGFloat = -64
    var oldScrollViewY: CGFloat = 0
    
    
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

        headerImageView = UIImageView(frame: CGRect(x: 0, y: headerImageYOffset, width: self.view.frame.width, height: self.view.frame.height / 2.5 + 30))
        headerImageView.contentMode = .ScaleAspectFill
        headerImageView.autoresizingMask = .FlexibleWidth
        self.view.insertSubview(headerImageView, belowSubview: tableView)
        
        headerActivityIndicator = UIActivityIndicatorView(frame: headerImageView.frame)
        headerActivityIndicator.hidesWhenStopped = true
        headerActivityIndicator.activityIndicatorViewStyle = .Gray
        self.view.insertSubview(headerActivityIndicator, aboveSubview: headerImageView)
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: headerImageView.frame.height + kDefaultHeaderImageYOffset * 2))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        MarvelCaching.caching.clearMemoryCache()
    }
    
    // TODO: "Character" header stays on screen when you scroll down
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let thumb = characterToDisplay?.thumbnailURL {
            let thumbURL = "\(thumb.path).\(thumb.ext)"
            
            MarvelCaching.caching.cachedImageForURLString(thumbURL, completion: { (image) -> Void in
                if image != nil {
                    self.headerImageView.image = image
                    return
                }
                
                self.headerActivityIndicator.startAnimating()
                MarvelNetworking.controller.getImageAtURLString(thumbURL, completion: { (image, errorString) -> Void in
                    self.headerActivityIndicator.stopAnimating()
                    if errorString != nil {
                        println(errorString)
                        return
                    }
                    
                    MarvelCaching.caching.setCachedImage(image!, forURLString: thumbURL)
                    
                    UIView.transitionWithView(self.headerImageView, duration: 0.3, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                        self.headerImageView.image = image
                    }, completion: nil)
                    
                })
                
            })
        }
        else {
            headerImageView.image = UIImage(named: "notfound_image_big.jpg")
        }
        
    }
    
    
    // MARK: MAIN TABLEVIEW
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionHeaderLabel = UILabel()
        sectionHeaderLabel.text = self.tableViewHeaders[section]
        sectionHeaderLabel.font = UIFont(name: "AvenirNext-Regular", size: 25.0)
        sectionHeaderLabel.textAlignment = NSTextAlignment.Center
        sectionHeaderLabel.textColor = UIColor.blackColor()
        sectionHeaderLabel.backgroundColor = UIColor.lightGrayColor()
        return sectionHeaderLabel
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.characterToDisplay?.bio == "" {
                return 2
            }
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var screenHeight = UIScreen.mainScreen().bounds.height
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else {
            var customCellHeight = screenHeight / 3.3
            return customCellHeight
        }
    }
    
    
    //TODO: Download more comics/series when the user scrolls to the end of thecollection view.
    //TODO: Add placeholder if there are no download results. Also add activity indicators before the collectionviews populate??
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 { // in the comics section
            let cell = self.tableView.dequeueReusableCellWithIdentifier("CUSTOM_CELL") as CustomTableViewCell
            
            self.comicsCollectionView = cell.customCollectionView
            
            cell.customCollectionView.delegate = self
            cell.customCollectionView.dataSource = self
            cell.customCollectionView.backgroundColor = UIColor.lightGrayColor()
            MarvelNetworking.controller.getComicsWithCharacterID(self.characterToDisplay!.id, limit: 6, completion: { (errorString, comicsArray, itemsLeft) -> Void in
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

            MarvelNetworking.controller.getSeriesWithCharacterID(self.characterToDisplay!.id, limit: 6, completion: { (errorString, seriesArray, itemsLeft) -> Void in
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
        cell.userInteractionEnabled = false
        println(self.tableView.numberOfRowsInSection(0))
        if self.tableView.numberOfRowsInSection(0) == 2 {
            if indexPath.row == 0 {
                cell.infoCellLabel.text = "\(self.characterToDisplay!.name)"
            } else {
                cell.infoCellLabel.text = "See more info"
                cell.userInteractionEnabled = true
                cell.accessoryType = UITableViewCellAccessoryType.DetailButton
            }
        }
        else {
            if indexPath.row == 0 {
                cell.infoCellLabel.text = "\(self.characterToDisplay!.name)"
            } else if indexPath.row == 1 {
                cell.infoCellLabel.text = "\(self.characterToDisplay!.bio)"
            } else {
                cell.infoCellLabel.text = "See more info"
                cell.userInteractionEnabled = true
                cell.accessoryType = UITableViewCellAccessoryType.DetailButton
            }
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
        cell.comicImageView.image = nil
        
        // determine the image url
        var sourceURL = ""
        if collectionView == self.comicsCollectionView {
            let currentComic = self.comicsForCharacter[indexPath.row]
            if let thumb = currentComic.thumbnailURL {
                sourceURL = "\(thumb.path)/portrait_xlarge.\(thumb.ext)"
            }
        }
        else {
            let currentSeries = self.seriesForCharacter[indexPath.row]
            if let thumb = currentSeries.thumbnailURL {
                sourceURL = "\(thumb.path)/portrait_xlarge.\(thumb.ext)"
            }
        }
        
        // Either grab the image from the cache or download it
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
                    
                    UIView.transitionWithView(cell.comicImageView, duration: 0.3, options: UIViewAnimationOptions.TransitionCurlDown, animations: { () -> Void in
                        cell.comicImageView.image = image
                        }, completion: nil)
                })
            }
        })
        
        return cell
    }

    // TODO: when returning from ComicOrSeriesVC, the CharacterDetailVC jumps to the top. maybe should stay scrolled down to wherever it was when the user selected a Comic or Series.
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var selectedComic : Comic
        var selectedSeries : Series
        var comicOrSeriesVC = storyboard?.instantiateViewControllerWithIdentifier("COMIC_OR_SERIES_VC") as ComicOrSeriesVC
        
        if collectionView == self.comicsCollectionView {
            println("comic selected at \(indexPath.row)")
            selectedComic = self.comicsForCharacter[indexPath.row] as Comic
            comicOrSeriesVC.comic = selectedComic
        }
        else {
            println("series selected at \(indexPath.row)")
            selectedSeries = self.seriesForCharacter[indexPath.row] as Series
            comicOrSeriesVC.series = selectedSeries
        }
        
        self.navigationController?.pushViewController(comicOrSeriesVC, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y;
        if scrollOffset < 0 {
            // Adjust image proportionally
            if -scrollOffset >= headerImageView.frame.height + kDefaultHeaderImageYOffset * 2 - 40 {
                scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, oldScrollViewY), animated: false)
                return
            }
            
            oldScrollViewY = scrollOffset
            headerImageView.frame.origin.y = headerImageYOffset - ((scrollOffset / 2));
        } else {
            headerImageView.frame.origin.y = headerImageYOffset - scrollOffset;
        }
    }
    
    @IBAction func learnMorePressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let webVC = storyboard.instantiateViewControllerWithIdentifier("WebVC") as WebVC

        if let character = self.characterToDisplay? {
            webVC.character = character
        }
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
}
