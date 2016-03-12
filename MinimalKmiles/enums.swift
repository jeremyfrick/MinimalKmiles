//
//  enums.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 2/21/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import Foundation

enum currentlyTracking: Int {
    case Yes = 0
    case No = 1
}
enum unitOfMeasurement: Int {
    case Miles = 0
    case Kilometers = 1
}
enum tripStatus: Int {
    case Start = 0
    case Stop = 1
}
