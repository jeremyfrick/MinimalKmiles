//
//  Converter.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 2/10/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import Foundation
class Converter{
    
    var measurement: unitOfMeasurement!
    
    func convert(measurement: Int, distance: Double) -> String {
        if unitOfMeasurement(rawValue: measurement) == unitOfMeasurement.Kilometers {
            return String.localizedStringWithFormat("%.1f",(distance / 1000))
        } else {
            return String.localizedStringWithFormat("%.1f",(distance / 1609.344))
        }

    }
    func convertToNumber(measurement: Int, distance: Double) -> Double {
        if unitOfMeasurement(rawValue: measurement) == unitOfMeasurement.Kilometers {
            return (distance / 1000)
        } else {
            return (distance / 1609.344)
        }

    }
    
    func convertFormatted(measurement: Int, distance: Double) -> String {
        if unitOfMeasurement(rawValue: measurement) == unitOfMeasurement.Kilometers {
            return String.localizedStringWithFormat("%.1f km",(distance / 1000))
        } else {
            return String.localizedStringWithFormat("%.1f miles",(distance / 1609.344))
        }

    }
    
    func convertAndSetSegmentBar(measurement: Int, distance: Double) -> (String, Int){
        if unitOfMeasurement(rawValue: measurement) == unitOfMeasurement.Kilometers {
            return (String.localizedStringWithFormat("%.1f",(distance / 1000)), 1)
        } else {
            return (String.localizedStringWithFormat("%.1f",(distance / 1609.344)), 0)
        }
    }
}