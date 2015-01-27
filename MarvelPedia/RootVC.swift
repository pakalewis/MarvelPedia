//
//  RootVC.swift
//  MarvelPedia
//
//  Created by Casey R White on 10/28/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class RootVC: UIViewController, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController!
    var pageFlipTimer: NSTimer?
    
    var characters = [Character]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
        
        // Prohibit pages flipping by user
        for recognizer in self.pageViewController.gestureRecognizers {
            if let recognizer = recognizer as? UIGestureRecognizer {
                recognizer.enabled = false
            }
        }
        self.pageViewController!.delegate = self
        
        let startingViewController: IntroPageVC = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers: NSArray = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        self.pageViewController!.didMoveToParentViewController(self)
        
        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        
        self.pageFlipTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "turnPage:", userInfo: nil, repeats: true)
        
    }
    
    var currentPageIndex = 0
    
    func turnPage(timer: NSTimer) {
        ++currentPageIndex
        if currentPageIndex < self.modelController.pageData.count {
            
            let startingViewController: IntroPageVC = self.modelController.viewControllerAtIndex(self.currentPageIndex, storyboard: self.storyboard!)!
            let viewControllers: NSArray = [startingViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })
            
        } else {
            timer.invalidate()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = storyboard.instantiateViewControllerWithIdentifier("HomeVC") as HomeVC
            let navController = UINavigationController(rootViewController: homeVC)
            
            // Make view with the Marvel.com label
            var window = (UIApplication.sharedApplication().delegate as AppDelegate).window
            
            
            var screenFrame = UIScreen.mainScreen().bounds
            var marvelLink = UIView(frame: CGRect(x: 0, y: screenFrame.size.height - 16, width: screenFrame.size.width, height: 16))
            marvelLink.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | .FlexibleWidth

            var labelFrame = CGRectMake(0, 0, marvelLink.frame.size.width, marvelLink.frame.size.height)
            var label = UILabel(frame: labelFrame)
            var button = UIButton(frame: labelFrame)
            button.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | .FlexibleWidth
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(10.0)
            button.setTitle("Data provided by MARVEL. © 2014 MARVEL", forState: .Normal)
            button.backgroundColor = UIColor.whiteColor()
            button.addTarget(self, action: "goToMarvel:", forControlEvents: UIControlEvents.TouchUpInside)

            
            marvelLink.addSubview(button)
            window?.addSubview(marvelLink);
            
            let viewControllers: NSArray = [navController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in
                self.pageViewController!.dataSource = nil
                self.pageViewController!.delegate = nil
            })
        }
    }
    
    func goToMarvel(sender: UIButton!) {
        var alertController = UIAlertController(title: "http://marvel.com", message: "Open in Safari?", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "http://marvel.com")!)
            return
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var modelController: IntroPageModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = IntroPageModelController()
        }
        return _modelController!
    }
    
    var _modelController: IntroPageModelController? = nil
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .Portrait) || (orientation == .PortraitUpsideDown) || (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
            let currentViewController = self.pageViewController!.viewControllers[0] as UIViewController
            let viewControllers: NSArray = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })
            
            self.pageViewController!.doubleSided = false
            return .Min
        }
        
        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers[0] as IntroPageVC
        var viewControllers: NSArray
        
        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfterViewController: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBeforeViewController: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })
        
        return .Mid
    }
    
}

