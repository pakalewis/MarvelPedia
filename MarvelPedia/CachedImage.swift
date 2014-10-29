//
//  CachedImage.swift
//  MarvelPedia
//
//  Created by Alex G on 28.10.14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation
import CoreData

class CachedImage: NSManagedObject {

    @NSManaged var imageURL: String
    @NSManaged var localPath: String

}
