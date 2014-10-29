//
//  Series.swift
//  MarvelPedia
//
//  Created by Parker Lewis on 10/28/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation



class Series {
    let id: Int
    let title: String
    let startYear: Int
    let endYear: Int
    let resourceURI: String
    let thumbnailURL: (path: String, ext: String)?
    
    init(data: NSDictionary) {
        self.id = data["id"] as Int
        self.title = data["title"] as String
        self.startYear = data["startYear"] as Int
        self.endYear = data["endYear"] as Int
        self.resourceURI = data["resourceURI"] as String
        
        if let thumbnail = data["thumbnail"] as? [String : String] {
            self.thumbnailURL = (path: thumbnail["path"]!, ext: thumbnail["extension"]!)
        }
    }
    
    
    
    class func parseJSONIntoSeries(#data: NSArray) -> [Series] {
        var series = [Series]()
        for seriesJSONObject in data {
            let seriesData = seriesJSONObject as NSDictionary
            let newSeries = Series(data: seriesData)
            series.append(newSeries)
        }
        
        return series
    }
}