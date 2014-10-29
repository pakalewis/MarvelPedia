//
//  TVCellWithCollectionView.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/28/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class TVCellWithCollectionView: UITableViewCell {

    
    @IBOutlet weak var customCollectionView: CustomCollectionView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let nib = UINib(nibName: "ComicCell", bundle: NSBundle.mainBundle())
        self.customCollectionView.registerNib(nib, forCellWithReuseIdentifier: "COMIC_CELL")
    
    }
}
