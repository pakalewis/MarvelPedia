//
//  CustomTableViewCell.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/28/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    
    @IBOutlet weak var customCollectionView: CustomCollectionView!
    var flowlayout: UICollectionViewFlowLayout!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let nib = UINib(nibName: "ComicCell", bundle: NSBundle.mainBundle())
        self.customCollectionView.registerNib(nib, forCellWithReuseIdentifier: "COMIC_CELL")
        
        self.flowlayout = self.customCollectionView.collectionViewLayout as UICollectionViewFlowLayout

        // grab screen size
        var screenWidth = UIScreen.mainScreen().bounds.width
        
        self.flowlayout.itemSize = CGSize(width: screenWidth / 3, height: 170)

        // check if device is iPad
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.flowlayout.itemSize = CGSize(width: screenWidth / 3, height: 220)
        }
    }
}
