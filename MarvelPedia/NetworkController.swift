//
//  NetworkController.swift
//  MarvelPedia
//
//  Created by Alex G on 27.10.14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation

import Foundation

var kNetworkControllerDefaultTimeout: NSTimeInterval = 10

extension Dictionary {
    func encodedStringForHTTPBody() -> String? {
        var retVal: NSData? = nil
        var partsArray = NSMutableArray()
        for (key, value) in self {
            if let nsStringKey = key as? NSString {
                if let nsStringValue = value as? NSString {
                    partsArray.addObject(NSString(format: "%@=%@", nsStringKey.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, nsStringValue.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!))
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
        
        return partsArray.componentsJoinedByString("&")
    }
}

extension NSURL {
    func dictionaryFromURL() -> NSDictionary {
        let queryString: NSString = self.query!
        let stringPairs = queryString.componentsSeparatedByString("&")
        var keyValuePairs = NSMutableDictionary()
        for pair in stringPairs {
            let bits = pair.componentsSeparatedByString("=")
            if bits.count > 1 {
                let key = (bits[0] as NSString).stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                let value = (bits[1] as NSString).stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                keyValuePairs.setObject(value!, forKey: key!)
            }
        }
        
        return keyValuePairs
    }
}

extension NSMutableURLRequest {
    func setBodyData(bodyData: NSData, isJSONData: Bool = false) {
        self.HTTPBody = bodyData
        self.setValue("\(bodyData.length)", forHTTPHeaderField: "Content-Length")
        self.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
    }
}

class NetworkController {
    
    // MARK: Public Properties
    /**
    Use with caution. Change only before starting th actual calls on a singleton.
    */
    var session = NSURLSession.sharedSession()
    var baseURL: String?
    
    // MARK: Class Properties
    class var controller: NetworkController {
        struct Struct {
            static var token: dispatch_once_t = 0
            static var instance: NetworkController! = nil
        }
        dispatch_once(&Struct.token, { () -> Void in
            Struct.instance = NetworkController()
        })
        return Struct.instance
    }
    
    // MARK: Life Cycle
    init() {
        
    }
    
    // MARK: Private Methods
    
    private func processResponse(response: NSURLResponse!, error: NSError!) -> String? {
        if error != nil {
            return error.localizedDescription
        }
        
        let HTTPResponse = response as NSHTTPURLResponse
        var errorString: String?
        switch HTTPResponse.statusCode {
        case 200...299:
            break
        case 400...499:
            errorString = "Client error"
        case 500...599:
            errorString = "Server error"
        default:
            errorString = "Unknown error"
        }
        
        if let errorString = errorString {
            return "\(errorString): \(HTTPResponse.statusCode)"
        }
        
        return nil
    }
    
    // MARK: Public Methods
    
    func downloadResourceWithURLString(URLString: String, completion: (localPath: String!, errorString: String!) -> Void) {
        let URL = NSURL(string: URLString)!
        let request = NSURLRequest(URL: URL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: kNetworkControllerDefaultTimeout)
        session.downloadTaskWithRequest(request, completionHandler: { (localURL, response, error) -> Void in
            
            if let errorString = self.processResponse(response, error: error) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(localPath: nil, errorString: errorString)
                })
                return
            }
            
            if localURL == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(localPath: nil, errorString: "Fatal error! Request succeed, but URL is nil!")
                })
                return
            }
            
            let localPath = NSTemporaryDirectory().stringByAppendingPathComponent(NSUUID().UUIDString)
            var error: NSError?
            NSFileManager.defaultManager().copyItemAtURL(localURL, toURL: NSURL(fileURLWithPath: localPath)!, error: &error)
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(localPath: nil, errorString: "Couldn't copy downloaded file: \(error!.localizedDescription)")
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(localPath: localPath, errorString: nil)
            })
            
        }).resume()
    }
    
    func performRequestWithURLPath(URLPath: String, method: String = "GET", parameters: [NSString: AnyObject]? = nil, acceptJSONResponse: Bool = false, sendBodyAsJSON: Bool = false, completion: (data: NSData!, errorString: String!) -> Void) {
        if let baseURL = baseURL {
            performRequestWithURLString(baseURL.stringByAppendingPathComponent(URLPath), method: method, parameters: parameters, acceptJSONResponse: acceptJSONResponse, sendBodyAsJSON: sendBodyAsJSON, completion: completion)
        }
        else {
            completion(data: nil, errorString: "Base URL not set")
        }
    }
    
    func performRequestWithURLString(URLString: String, method: String = "GET", parameters: [NSString: AnyObject]? = nil, acceptJSONResponse: Bool = false, sendBodyAsJSON: Bool = false, completion: (data: NSData!, errorString: String!) -> Void) {
        let URL = NSURL(string: URLString)!
        let request = NSMutableURLRequest(URL: URL, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: kNetworkControllerDefaultTimeout)
        request.HTTPMethod = method
        
        if acceptJSONResponse {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        if parameters != nil {
            switch method {
            case "POST", "PUT", "DELETE", "PATCH":
                var bodyData: NSData! = nil
                if sendBodyAsJSON {
                    var error: NSError?
                    bodyData = NSJSONSerialization.dataWithJSONObject(parameters!, options: nil, error: &error)
                    if error != nil {
                        completion(data: nil, errorString: "Error building JSON: \(error?.localizedDescription)")
                        return
                    }
                }
                else {
                    if let encodedString = parameters!.encodedStringForHTTPBody() {
                        bodyData = encodedString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                    }
                }
                
                if bodyData == nil {
                    completion(data: nil, errorString: "Couldn't create bodyData")
                    return
                }
                
                request.setBodyData(bodyData, isJSONData: sendBodyAsJSON)
                
            default:
                if let encodedString = parameters!.encodedStringForHTTPBody() {
                    let URL = NSURL(string: URLString + "?" + encodedString)
                    request.URL = URL
                }
                break
            }
            
            
        }
        
        session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let errorString = self.processResponse(response, error: error) {
                    completion(data: data, errorString: errorString)
                    return
                }
                
                if data == nil {
                    completion(data: nil, errorString: "Fatal error! Request succeed, but data is nil!")
                    return
                }
                
                completion(data: data, errorString: nil)
            })
        }).resume()
    }
}