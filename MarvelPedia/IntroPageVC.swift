//
//  IntroPageVC.swift
//  MarvelPedia
//
//  Created by Casey R White on 10/28/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class IntroPageVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageToDisplay: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let image = self.imageToDisplay {
            self.imageView.image = image
        }
    }


}
