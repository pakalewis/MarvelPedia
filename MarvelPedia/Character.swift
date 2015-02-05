//
//  Character.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/27/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation


class Character {
    
    let id: Int
    let name: String
    let bio: String
    let modified: String
    let resourceURI: String
    let thumbnailURL: (path: String, ext: String)?
    let detailURL: String?
    
    init(data: NSDictionary) {
        self.id = data["id"] as Int
        self.name = data["name"] as String
        self.bio = data["description"] as String
        self.modified = data["modified"] as String
        self.resourceURI = data["resourceURI"] as String
        
        if let thumbnail = data["thumbnail"] as? [String : String] {
            self.thumbnailURL = (path: thumbnail["path"]!, ext: thumbnail["extension"]!)
        }
        
        if let urls = data["urls"] as? NSArray {
            if let detailDict = urls[0] as? [String : String] {
                let type = detailDict["type"]
                if type == "detail" {
                    if let url = detailDict["url"] {
                        if !url.isEmpty {
                            self.detailURL = url
                        }
                    }
                }
            }
        }
    }
    
    class func parseJSONIntoCharacters(#data: NSArray) -> [Character] {
        var characters = [Character]()
        for characterJSONObject in data {
            let characterData = characterJSONObject as NSDictionary
            let newCharacter = Character(data: characterData)
            characters.append(newCharacter)
        }
        
        return characters
    }
}