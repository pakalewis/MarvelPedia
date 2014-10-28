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
    private var predefinedParams: [NSString : AnyObject] {
        get {
            var retVal = [NSString : AnyObject]()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let timeStampString = formatter.stringFromDate(NSDate())
            let hashString = (timeStampString + kMarvelPediaPrivateKey + kMarvelPediaPublicKey).md5()
            
            retVal["apikey"] = kMarvelPediaPublicKey
            retVal["hash"] = hashString
            retVal["ts"] = timeStampString
            return retVal
        }
    }
    
    // MARK: Public Methods
    /**
    Performs a request to get characters.
    
    :param: nameQuery Optional. If provided, method returns characters with names that begin with the specified string (e.g. Sp)
    :param: startIndex Optional. If provided, method returns results starting with specified index for pagination.
    :param: limit Optional. If provided, limits the number of characters returned at once. Maximum value is 100.
    :param: completion The completion handler to call when the request is complete. If errorString isn't nil, charactersArray contains an array of characters stored in NSDictionary
    
    */
    
    func getCharacters(nameQuery q: String? = nil, startIndex: Int? = nil, limit: Int? = nil, completion: (errorString: String?, charactersArray: NSArray?) -> Void) {
        var parameters: [NSString : AnyObject]! = [NSString : AnyObject]()
        parameters["nameStartsWith"] = q?
        parameters["offset"] = startIndex?
        
        if limit? > 0 {
            parameters["limit"] = limit > 100 ? 100 : limit
        }
        
        if parameters.isEmpty {
            parameters = nil
        }
        
        performRequestWithURLPath("/characters", parameters: parameters, completion: {(data, errorString) -> Void in
            self.processJSONData(data, errorString: errorString, completion: { (responseDic, errorString) -> Void in
                if errorString != nil {
                    completion(errorString: errorString, charactersArray: nil)
                    return
                }
                
                if let resultArray = (responseDic?["data"] as? NSDictionary)?["results"] as? NSArray {
                    completion(errorString: nil, charactersArray: resultArray)
                }
                else {
                    completion(errorString: "No \"data\" or \"results\" objects in dictionary", charactersArray: nil)
                }
            })
        })
    }
    
    // MARK: Public Methods
    /**
    Performs a request to get image data.
    
    :param: URLString A string that represents the desired URL. Cannot be nil.
    :param: completion The completion handler to call when the request is complete. If errorString isn't nil, image contains an UIImage object.
    
    */
    
    func getImageAtURLString(URLString: String, completion: (image: UIImage?, errorString: String?) -> Void) {
        self.performRequestWithURLString(URLString, completion: { (data, errorString) -> Void in
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
    private func processJSONData(data: NSData?, errorString: String?, completion: (responseDic: NSDictionary?, errorString: String?) -> Void) {
        
        var newErrorString = errorString
        if data != nil {
            var error: NSError?
            if let retValDic = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as? NSDictionary {
                if errorString != nil {
                    println("Error from Marvel:")
                    println(retValDic)
                    completion(responseDic: nil, errorString: newErrorString)
                    return
                }
                
                completion(responseDic: retValDic, errorString: nil)
                return
            }
            
            if let errorJSON = error {
                newErrorString = errorJSON.localizedDescription
                completion(responseDic: nil, errorString: "Error parsing JSON response: \(newErrorString)")
            }
        }
        else {
            completion(responseDic: nil, errorString: newErrorString)
        }
    }
    
    // Overrides
    
    override func performRequestWithURLString(URLString: String, method: String = "GET", parameters: [NSString: AnyObject]? = nil, acceptJSONResponse: Bool = false, sendBodyAsJSON: Bool = false, completion: (data: NSData!, errorString: String!) -> Void) {
        var finalParams = parameters == nil ? [NSString : AnyObject]() : parameters
        finalParams!.append(predefinedParams)
        
        super.performRequestWithURLString(URLString, method: method, parameters: finalParams, acceptJSONResponse: true, sendBodyAsJSON: sendBodyAsJSON, completion: completion)
    }
    
    
}