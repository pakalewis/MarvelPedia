//
//  SeriesCell.swift
//  MarvelPedia
//
//  Created by Alex G on 31.10.14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class SeriesCell: UICollectionViewCell {
    @IBOutlet weak var comicImageView: UIImageView!
    
    @IBOutlet weak var comicTitleLabel: UILabel!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
