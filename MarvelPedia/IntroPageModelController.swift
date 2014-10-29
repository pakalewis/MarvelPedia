//
//  IntroPageModelController.swift
//  MarvelPedia
//
//  Created by Casey R White on 10/28/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class IntroPageModelController: NSObject, UIPageViewControllerDataSource {

    var pageData = NSMutableArray()


    override init() {
        super.init()
        // Create the data model.
        
        for index in 1...6 {
            let imageName = "comic\(index).jpg"
            let image = UIImage(named: imageName)
            self.pageData.addObject(image!)
        }
    }

    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> IntroPageVC? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("IntroPageVC") as IntroPageVC
        dataViewController.imageToDisplay = self.pageData[index] as? UIImage
        return dataViewController
    }

    func indexOfViewController(viewController: IntroPageVC) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        if let image = viewController.imageToDisplay {
            return self.pageData.indexOfObject(image)
        } else {
            return NSNotFound
        }
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as IntroPageVC)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as IntroPageVC)
        if index == NSNotFound {
            return nil
        }
        
        index++
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }


}

