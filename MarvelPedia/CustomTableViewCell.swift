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

        self.flowlayout.itemSize = CGSize(width: 100.0, height: 150.0)

        // check if device is iPad
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.flowlayout.itemSize = CGSize(width: 200.0, height: 300.0)
        }
    }
}
