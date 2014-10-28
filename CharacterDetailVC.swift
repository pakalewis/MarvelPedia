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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
//        let headerNib = UINib(nibName: "TableHeader", bundle: NSBundle.mainBundle())
//        let headerView = UIView(
//        self.tableView.tableHeaderView = headerNib
//
//        let headerView = NSBundle.mainBundle().loadNibNamed("TableHeader", owner: self, options: nil)
        
        // register InfoCell nib for the tableview
        let nib = UINib(nibName: "InfoCell", bundle: NSBundle.mainBundle())
        self.tableView.registerNib(nib, forCellReuseIdentifier: "INFO_CELL")
        
        let newNib = UINib(nibName: "TVCellWithCollectionView", bundle: nil)
        self.tableView.registerNib(newNib, forCellReuseIdentifier: "TVCELL")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 1 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("TVCELL") as TVCellWithCollectionView
            cell.frenemyCV.delegate = self
            cell.frenemyCV.dataSource = self
            return cell
        }
        
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("INFO_CELL", forIndexPath: indexPath) as InfoCell
        cell.textLabel.text = "\(self.characterToDisplay?.name)"

        
        
        // modify the thumbnail url in order to download a larger version of the character's image
        if let thumb = self.characterToDisplay!.thumbnailURL {
            var urlForLargerImage = "\(thumb.path)/portrait_uncanny.\(thumb.ext)"
            MarvelNetworking.controller.getImageAtURLString(urlForLargerImage, completion: { (image, errorString) -> Void in
                // load the larger image into the header
            })
        }
        
        return cell
        
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CHARACTER_CELL", forIndexPath: indexPath) as CharacterCell
        
        // pull the enemy or friend from an array and grab it's name and image
        cell.imageView.backgroundColor = UIColor.blueColor()
        return cell
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("frenemy selected at \(indexPath.row)")
        
        var characterDetailVC = storyboard?.instantiateViewControllerWithIdentifier("CHARACTER_DETAIL_VC") as CharacterDetailVC

        // grab the selected frenemy and pass on to another CharacterDetailVC
        //        characterDetailVC.characterToDisplay = self.characters[indexPath.row]
        
//        self.navigationController?.pushViewController(characterDetailVC, animated: true)
    }
    
    
    
    
    
    
//    tabl
//    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("HEADER") as TableHeader
//        return header
//    }
    
}
