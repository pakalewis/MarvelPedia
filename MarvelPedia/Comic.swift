//
//  Comic.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/28/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation


class Comic {
    let id: Int
    let title: String
    let description: String?
    let resourceURI: String
    let thumbnailURL: (path: String, ext: String)?
    
    init(data: NSDictionary) {
        self.id = data["id"] as Int
        self.title = data["title"] as String
        self.description = data["description"] as? String
        self.resourceURI = data["resourceURI"] as String
        
        if let thumbnail = data["thumbnail"] as? [String : String] {
            self.thumbnailURL = (path: thumbnail["path"]!, ext: thumbnail["extension"]!)
        }
    }
    
    
    
    class func parseJSONIntoComics(#data: NSArray) -> [Comic] {
        var comics = [Comic]()
        for comicJSONObject in data {
            let comicData = comicJSONObject as NSDictionary
            let newComic = Comic(data: comicData)
            comics.append(newComic)
        }
        
        return comics
    }
}