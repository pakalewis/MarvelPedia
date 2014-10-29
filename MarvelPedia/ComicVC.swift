//
//  ComicVC.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/29/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class ComicVC: UIViewController {

    var comic: Comic?
    @IBOutlet var comicImageView : UIImageView!
    @IBOutlet var comicTitleLabel : UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        self.comicImageView.back
        self.comicTitleLabel.text = self.comic!.title
    }

}
