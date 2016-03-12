//
//  Trip.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 9/27/14.
//  Copyright (c) 2014 Red Anchor Software. All rights reserved.
//

import Foundation
import CoreData

class Trip: NSManagedObject {
    @NSManaged var miles: Int16
    @NSManaged var distance: Float
    @NSManaged var purpose: String
    @NSManaged var timestamp: NSDate
    @NSManaged var rawdistance: Double
    @NSManaged var notes: String
}