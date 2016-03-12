import Foundation

class ReportPrinter {
    
    var converter = Converter()
    let formatter = NSDateFormatter()
    var measurement: unitOfMeasurement!

    func currentDate() -> String {
        let date = NSDate()
        formatter.dateStyle = .ShortStyle
        return formatter .stringFromDate(date)
    }

    func buildShareReport(measurement: String, distanceTravled: String, purposeOfTrip: String) ->(shareText: String, sharePrintText: String) {
        
        var shareText: String?
        var sharePrintText: String?
	
        switch measurement {
		case "Miles":
		let formattedMilage = distanceTravled + " miles"
            
            shareText = "Date:  \(currentDate())\nMilage:  \(formattedMilage) \nPurpose of Trip:  \(purposeOfTrip)"
            sharePrintText = "\t\t\t***Mileage Report***\n Date: \(currentDate())\tMilage: \(formattedMilage) \tPurpose of Trip: \(purposeOfTrip)"
        
		case "km":
		let formattedMilage = distanceTravled + " km"
            
            shareText = "Date:  \(currentDate())\nMilage:  \(formattedMilage) \nPurpose of Trip:  \(purposeOfTrip)"
            sharePrintText = "\t\t\t***Mileage Report***\n Date: \(currentDate())\tMilage: \(formattedMilage) \tPurpose of Trip: \(purposeOfTrip)"
    
		default:
			break
			
        }
        
        return(shareText!, sharePrintText!)
	}
    
    func BuildMultiTripReport(trips: Array<Trip>) -> String {
        
        var printedData = "|****DATE****|****DISTANCE****|****PURPOSE****|\n\n"
        var totalDistanceForPeriodMiles = 0.0
        var totalDistanceForPeriodKms = 0.0
        
        for trip in trips{
            formatter.dateStyle = .ShortStyle
            let tripMeasurement = trip.miles
            measurement = unitOfMeasurement(rawValue: Int(tripMeasurement))!
            let distance = converter.convertToNumber(measurement.rawValue , distance:trip.rawdistance)
            if measurement == unitOfMeasurement.Miles {
                totalDistanceForPeriodMiles = totalDistanceForPeriodMiles + distance
                let formattedMilage :NSString = String(format: "%.01f miles",distance)
                printedData = printedData + "| \(formatter.stringFromDate(trip.timestamp))        | \(formattedMilage)              | \(trip.purpose)\n\n"
            }else{
                totalDistanceForPeriodKms = totalDistanceForPeriodKms + distance
                let formattedMilage :NSString = String(format: "%.01f km",distance)
                printedData = printedData + "| \(formatter.stringFromDate(trip.timestamp))        | \(formattedMilage)              | \(trip.purpose)\n\n"
            }
        }
        
        let formattedMilesTotalDistance : NSString = String(format: "%.01f",totalDistanceForPeriodMiles)
        let formattedKmTotalDistance:NSString = String(format:"%.01f",totalDistanceForPeriodKms)
        
        printedData = printedData + "TOTAL MILAGE FOR THE PERIOD:  \(formattedMilesTotalDistance) MILES.\n"
        printedData = printedData + "TOTAL KM FOR THE PERIOD: \(formattedKmTotalDistance) KM.\n"
        
        return printedData
    }
}