//
//  TVCellWithCollectionView.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/28/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class TVCellWithCollectionView: UITableViewCell {

    
    @IBOutlet weak var frenemyCV: FrenemyCollectionView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let nib = UINib(nibName: "CharacterCell", bundle: NSBundle.mainBundle())
        self.frenemyCV.registerNib(nib, forCellWithReuseIdentifier: "CHARACTER_CELL")
    
    }
}
