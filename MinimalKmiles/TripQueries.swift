//
//  TripQueries.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 2/8/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import Foundation
import CoreData


class TripQueries {
    
    var managedObjectContext: NSManagedObjectContext!
    
    func getTripsForReport(test: NSManagedObjectContext)->Array<Trip> {

        let fReq: NSFetchRequest = NSFetchRequest(entityName: "Trip")
        let sorter : NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fReq.sortDescriptors = [sorter]
        
        fReq.returnsObjectsAsFaults = false
        var result: [AnyObject]?
        do {
            result = try test.executeFetchRequest(fReq)
        } catch let error as NSError {
            print("error \(error.localizedDescription)")
            result = nil
        }
        
        return result! as! Array<Trip>
        
    }
    func getTripsForReport(test: NSManagedObjectContext, numberofDays: Int)->Array<Trip> {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        let calendar = NSCalendar.currentCalendar()
        let today = NSDate()
        let startDate = calendar.dateByAddingUnit(.Day, value: numberofDays, toDate: today, options: NSCalendarOptions.init(rawValue: 0))
        
        let fReq: NSFetchRequest = NSFetchRequest(entityName: "Trip")
        fReq.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate!, today)
        let sorter : NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fReq.sortDescriptors = [sorter]
        
        fReq.returnsObjectsAsFaults = false
        var result: [AnyObject]?
        do {
            result = try test.executeFetchRequest(fReq)
        } catch let error as NSError {
            print("error \(error.localizedDescription)")
            result = nil
        }
        
        return result! as! Array<Trip>
    }

    
    func getTripsForReport(test: NSManagedObjectContext, startDate: NSDate, endDate: NSDate)->Array<Trip> {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        let calendar = NSCalendar.currentCalendar()
        let daysToSubtract = -1
        let modifiedStartDate = calendar.dateByAddingUnit(.Day, value: daysToSubtract, toDate: startDate, options: NSCalendarOptions.init(rawValue: 0))
        
        let fReq: NSFetchRequest = NSFetchRequest(entityName: "Trip")
        fReq.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", modifiedStartDate!, endDate)
        let sorter : NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fReq.sortDescriptors = [sorter]
        fReq.returnsObjectsAsFaults = false
        
        var result: [AnyObject]?
        do {
            result = try test.executeFetchRequest(fReq)
        } catch let error as NSError {
            print("error \(error.localizedDescription)")
            result = nil
        }
        
        return result! as! Array<Trip>
    }

}