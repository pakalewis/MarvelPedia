//
//  CharacterDetailVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/27/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class CharacterDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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

//    tabl
//    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("HEADER") as TableHeader
//        return header
//    }
    
}
