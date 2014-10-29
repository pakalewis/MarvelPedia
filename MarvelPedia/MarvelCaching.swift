//
//  MarvelCaching.swift
//  MarvelPedia
//
//  Created by Alex G on 28.10.14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit

class MarvelCaching {
    
    // MARK: Class Properties
    class var caching: MarvelCaching {
        struct Struct {
            static var token: dispatch_once_t = 0
            static var instance: MarvelCaching! = nil
        }
        dispatch_once(&Struct.token, { () -> Void in
            Struct.instance = MarvelCaching()
        })
        return Struct.instance
    }
    
    // MARK: Public Properties

    // MARK: Private Properties
    // The maximum number of images stored in memory
    private let kMarvelMaxCacheSize = 50
    private var queue = Queue<String>()
    private var imagesDic = [String: UIImage]()
    
    // MARK: Public Methods
    func setChachedImage(image: UIImage, forURLString URLString: String) {
        if imagesDic[URLString] != nil {
            return
        }
        
        // Use queue to control the maximum number of cached images
        if queue.size == kMarvelMaxCacheSize {
            if let curURLString = queue.dequeue() {
                imagesDic.removeValueForKey(curURLString)
                println("Dequeued \(curURLString)")
            }
        }
        
        queue.enqueue(URLString)
        
        imagesDic[URLString] = image
    }
    
    func cachedImageForURLString(URLString: String) -> UIImage? {
        return imagesDic[URLString]
    }
    
    // MARK: Private Methods
    
    
}