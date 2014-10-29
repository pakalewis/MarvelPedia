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
    private let kMarvelMaxCacheSize = 80
    private var queue = Queue<String>()
    private var imagesDic = [String: UIImage]()
    
    // MARK: Public Methods
    /**
    Puts UIImage object into cache.
    
    :param: image An UIImage object to be put into cache.
    :param: forURLString String containing image original URL.
    
    */
    func setCachedImage(image: UIImage, forURLString URLString: String) {
        if imagesDic[URLString] != nil {
            return
        }
        
        // Use queue to control the maximum number of cached images
        if queue.size == kMarvelMaxCacheSize {
            // Remove half of the oldest items from cache to load new items
            dropImagesToDiscWithCount(kMarvelMaxCacheSize / 2)
        }
        
        queue.enqueue(URLString)
        
        imagesDic[URLString] = image
    }
    
    /**
    Gets UIImage object from cache.
    
    :param: URLString String containing image original URL.
    
    :return: UIImage object associated with URL or nil if not found in cache.
    
    */
    func cachedImageForURLString(URLString: String, completion: (UIImage?) -> Void) {
        if let imageFromMemory = imagesDic[URLString] {
            completion(imageFromMemory)
            return
        } else {
            // No image found in memory cache, try Core Data.
            if let cachedImagesArray = CoreDataManager.manager.fetchObjectsWithEntityClass(CachedImage.classForCoder(), predicateFormat: "imageURL == %@", URLString) {
                if let cachedImage = cachedImagesArray.first as? CachedImage {
                    // Got image's path
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        if let imageFromDisc = UIImage(contentsOfFile: cachedImage.localPath) {
                            // Image is found on disc and is loaded.
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                // Put the loaded image into memory cache.
                                self.setCachedImage(imageFromDisc, forURLString: URLString)
                                completion(imageFromDisc)
                            })
                        }
                        else {
                            // Couldn't load image from path, so delete the object from CoreData
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                CoreDataManager.manager.deleteObject(cachedImage)
                                CoreDataManager.manager.saveContext()
                                completion(nil)
                            })
                        }
                        
                    })
                    return
                }
            }
        }
        
        completion(nil)
        
    }
    
    /**
    Removes all objects from memory cache.
    */
    func clearMemoryCache() {
        dropImagesToDiscWithCount()
//        for i in 0..<queue.size {
//            if let curURLString = queue.dequeue() {
//                imagesDic.removeValueForKey(curURLString)
//            }
//        }
    }
    
    // MARK: Private Methods
    private func dropImagesToDiscWithCount(var _ count: Int! = nil) {
        if (count == nil) || (count > queue.size) {
            count = queue.size
        }
        
        for i in 0..<count {
            if let curURLString = queue.dequeue() {
                if let image = imagesDic[curURLString] {
                    // Create new CachedImage object only if it's not already there
                    if CoreDataManager.manager.countObjectsWithEntityClass(CachedImage.classForCoder(), predicateFormat: "imageURL == %@", curURLString) == 0 {
                        if let cachedImage = CoreDataManager.manager.newObjectForEntityClass(CachedImage) as? CachedImage {
                            cachedImage.imageURL = curURLString
                            
                            if let pathList = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) {
                                if var pathString = pathList.first as? NSString {
                                    if let path = NSURL(fileURLWithPath: pathString.stringByAppendingPathComponent(NSUUID().UUIDString)) {
                                        if UIImagePNGRepresentation(image).writeToURL(path, atomically: false) {
                                            cachedImage.localPath = path.path!
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                imagesDic.removeValueForKey(curURLString)
            }
        }
        
        CoreDataManager.manager.saveContext()
    }
    
}