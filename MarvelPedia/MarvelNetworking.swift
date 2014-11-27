//
//  MarvelNetworking.swift
//  MarvelPedia
//
//  Created by Alex G on 27.10.14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary {
    mutating func append(dic: Dictionary) {
        for (key,value) in dic {
            self.updateValue(value, forKey:key)
        }
    }
}

extension String {
    func md5() -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CC_MD5(str!, strLen, result)
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.destroy()
        return String(format: hash)
    }
}

class MarvelNetworking: NetworkController {
    
    // MARK: Class Properties
    override class var controller: MarvelNetworking {
        struct Struct {
            static var token: dispatch_once_t = 0
            static var instance: MarvelNetworking! = nil
        }
        dispatch_once(&Struct.token, { () -> Void in
            Struct.instance = MarvelNetworking()
            Struct.instance.baseURL = "http://gateway.marvel.com/v1/public"
        })
        return Struct.instance
    }
    
    // MARK: Private Properties
    private var predefinedParams: [NSString : AnyObject]? {
        get {
            if let keysDictionary = Pairs.singleton.getKeyPair() {
                var retVal = [NSString : AnyObject]()
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                let timeStampString = formatter.stringFromDate(NSDate())
                let privateKey = keysDictionary["privateKey"] as String
                let publicKey = keysDictionary["publicKey"] as String
                let hashString = (timeStampString + privateKey + publicKey).md5()
                
                retVal["apikey"] = publicKey
                retVal["hash"] = hashString
                retVal["ts"] = timeStampString
                    
                return retVal
            }
            
            return nil
        }
    }
    
    // MARK: Public Methods
    /**
    Performs a request to get characters.
    
    :param: nameQuery Optional. If provided, method returns characters with names that begin with the specified string (e.g. Sp)
    :param: startIndex Optional. If provided, method returns results starting with specified index for pagination.
    :param: limit Optional. If provided, limits the number of objects returned at once. Maximum value is 100.
    :param: completion The completion handler to call when the request is complete. If errorString isn't nil, charactersArray contains an array of characters stored in NSDictionary
    
    */
    
    func getCharacters(nameQuery q: String? = nil, startIndex: Int? = nil, limit: Int? = nil, completion: (errorString: String?, charactersArray: NSArray?, itemsLeft: Int?) -> Void) -> NSURLSessionDataTask? {
        var parameters: [NSString : AnyObject]! = [NSString : AnyObject]()
        parameters["nameStartsWith"] = q?
        if parameters.isEmpty {
            parameters = nil
        }
        
        return getObjectsWithPath("/characters", params: parameters, startIndex: startIndex, limit: limit, completion: completion)
    }
    
    /**
    Performs a request to get comics.
    
    :param: titleQuery Optional. If provided, method returns comics with titles that begin with the specified string (e.g. X-)
    :param: startIndex Optional. If provided, method returns results starting with specified index for pagination.
    :param: limit Optional. If provided, limits the number of objects returned at once. Maximum value is 100.
    :param: completion The completion handler to call when the request is complete. If errorString isn't nil, comicsArray contains an array of comics stored in NSDictionary
    
    */
    
    func getComics(titleQuery q: String? = nil, startIndex: Int? = nil, limit: Int? = nil, completion: (errorString: String?, comicsArray: NSArray?, itemsLeft: Int?) -> Void) -> NSURLSessionDataTask? {
        var parameters: [NSString : AnyObject]! = [NSString : AnyObject]()
        parameters["titleStartsWith"] = q?
        if parameters.isEmpty {
            parameters = nil
        }
        
        return getObjectsWithPath("/comics", params: parameters, startIndex: startIndex, limit: limit, completion: completion)
    }
    
    /**
    Performs a request to get comics for specified character.
    
    :param: charID ID of the character.
    :param: startIndex Optional. If provided, method returns results starting with specified index for pagination.
    :param: limit Optional. If provided, limits the number of objects returned at once. Maximum value is 100.
    :param: completion The completion handler to call when the request is complete. If errorString isn't nil, comicsArray contains an array of comics stored in NSDictionary
    
    */
    
    func getComicsWithCharacterID(charID: Int, startIndex: Int? = nil, limit: Int? = nil, completion: (errorString: String?, comicsArray: NSArray?, itemsLeft: Int?) -> Void) {
        
        getObjectsWithPath("/characters/\(charID)/comics", startIndex: startIndex, limit: limit, completion: completion)
    }
    
    /**
    Performs a request to get characters for specified comic ID.
    
    :param: comicID ID of the comic.
    :param: startIndex Optional. If provided, method returns results starting with specified index for pagination.
    :param: limit Optional. If provided, limits the number of objects returned at once. Maximum value is 100.
    :param: completion The completion handler to call when the request is complete. If errorString isn't nil, comicsArray contains an array of characters stored in NSDictionary
    
    */
    func getCharactersWithComicID(comicID: Int, startIndex: Int? = nil, limit: Int? = nil, completion: (errorString: String?, charactersArray: NSArray?, itemsLeft: Int?) -> Void) {
        
        getObjectsWithPath("/comics/\(comicID)/characters", startIndex: startIndex, limit: limit, completion: completion)
    }
    
    /**
    Performs a request to get characters for specified comic ID.
    
    :param: seriesID ID of the series.
    :param: startIndex Optional. If provided, method returns results starting with specified index for pagination.
    :param: limit Optional. If provided, limits the number of objects returned at once. Maximum value is 100.
    :param: completion The completion handler to call when the request is complete. If errorString isn't nil, comicsArray contains an array of characters stored in NSDictionary
    
    */
    func getCharactersWithSeriesID(seriesID: Int, startIndex: Int? = nil, limit: Int? = nil, completion: (errorString: String?, charactersArray: NSArray?, itemsLeft: Int?) -> Void) {
        
        getObjectsWithPath("/series/\(seriesID)/characters", startIndex: startIndex, limit: limit, completion: completion)
    }
    
    /**
    Performs a request to get series for specified character.
    
    :param: seriesID ID of the series.
    :param: startIndex Optional. If provided, method returns results starting with specified index for pagination.
    :param: limit Optional. If provided, limits the number of objects returned at once. Maximum value is 100.
    :param: completion The completion handler to call when the request is complete. If errorString isn't nil, seriesArray contains an array of series stored in NSDictionary
    
    */
    
    func getSeriesWithCharacterID(charID: Int, startIndex: Int? = nil, limit: Int? = nil, completion: (errorString: String?, seriesArray: NSArray?, itemsLeft: Int?) -> Void) {
        getObjectsWithPath("/characters/\(charID)/series", startIndex: startIndex, limit: limit, completion: completion)
    }
    
    /**
    Performs a request to get image data.
    
    :param: URLString A string that represents the desired URL. Cannot be nil.
    :param: completion The completion handler to call when the request is complete. If errorString isn't nil, image contains an UIImage object.
    
    */
    
    func getImageAtURLString(URLString: String, completion: (image: UIImage?, errorString: String?) -> Void) {
        super.performRequestWithURLString(URLString, completion: { (data, errorString) -> Void in
            if errorString != nil {
                completion(image: nil, errorString: errorString)
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let image = UIImage(data: data)
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    if image == nil {
                        completion(image: nil, errorString: "Couldn't create image from data")
                        return
                    }
                    
                    completion(image: image, errorString: nil)
                })
            })
        })
    }
    
    // MARK: Private Methods
    private func getObjectsWithPath(URLPath: String, params: [NSString : AnyObject]? = nil, startIndex: Int? = nil, limit: Int? = nil, completion: (errorString: String?, charactersArray: NSArray?, itemsLeft: Int?) -> Void) -> NSURLSessionDataTask? {
        var parameters: [NSString : AnyObject]! = [NSString : AnyObject]()
        if let extParams = params {
            for (key, value) in extParams {
                parameters[key] = value
            }
        }
        
        parameters["offset"] = startIndex?
        if limit? > 0 {
            parameters["limit"] = limit > 100 ? 100 : limit
        }
        
        if parameters.isEmpty {
            parameters = nil
        }
        
        return performRequestWithURLPath(URLPath, parameters: parameters, completion: {(data, errorString) -> Void in
            self.processJSONData(data, errorString: errorString, completion: { (responseArray, errorString, itemsLeft) -> Void in
                completion(errorString: nil, charactersArray: responseArray, itemsLeft: itemsLeft)
            })
        })
    }
    
    private func processJSONData(data: NSData?, errorString: String?, completion: (responseArray: NSArray?, errorString: String?, itemsLeft: Int?) -> Void) {
        
        var newErrorString = errorString
        if data != nil {
            var error: NSError?
            if let responseDic = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as? NSDictionary {
                if errorString != nil {
                    println("Error from Marvel:")
                    println(responseDic)
                    completion(responseArray: nil, errorString: newErrorString, itemsLeft: nil)
                    return
                }
                
                if let dataDic = responseDic["data"] as? NSDictionary {
                    // Check the number of items left to load
                    var itemsLeft: Int = 0
                    if let offset = dataDic["offset"] as? Int {
                        if let count = dataDic["count"] as? Int {
                            if let total = dataDic["total"] as? Int {
                                itemsLeft = total - (offset + count)
                            }
                        }
                    }
                    
                    // Return the results array in completion handler
                    if let resultArray = dataDic["results"] as? NSArray {
                        completion(responseArray: resultArray, errorString: nil, itemsLeft: itemsLeft)
                        return
                    }
                }
                
                completion(responseArray: nil, errorString: "No \"data\" or \"results\" objects in dictionary", itemsLeft: nil)
                return
            }
            
            if let errorJSON = error {
                newErrorString = errorJSON.localizedDescription
                completion(responseArray: nil, errorString: "Error parsing JSON response: \(newErrorString)", itemsLeft: nil)
            }
        }
        else {
            completion(responseArray: nil, errorString: newErrorString, itemsLeft: nil)
        }
    }
    
    // MARK: Overrides
    
    override func performRequestWithURLString(URLString: String, method: String = "GET", parameters: [NSString: AnyObject]? = nil, acceptJSONResponse: Bool = false, sendBodyAsJSON: Bool = false, completion: (data: NSData!, errorString: String!) -> Void) -> NSURLSessionDataTask? {
        var finalParams = parameters == nil ? [NSString : AnyObject]() : parameters
        if (predefinedParams != nil) {
            finalParams!.append(predefinedParams!)
            return super.performRequestWithURLString(URLString, method: method, parameters: finalParams, acceptJSONResponse: true, sendBodyAsJSON: sendBodyAsJSON, completion: completion)
        }
        
        completion(data: nil, errorString: "Rate exceeded for keys")
        return nil
    }
    
    
}