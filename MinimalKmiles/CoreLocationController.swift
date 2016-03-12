//
//  CoreLocationController.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 3/18/15.
//  Copyright (c) 2015 Red Anchor Software. All rights reserved.
//

import Foundation
import CoreLocation

class CoreLocationController : NSObject, CLLocationManagerDelegate {
    lazy var locationManager = CLLocationManager()
    lazy var locations = [CLLocation]()
    var locationFixAchieved = false
    var distanceMoved = 0.0
    
    override init(){
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
    }
   

    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            print(".NotDetermined")
            break
            
        case .AuthorizedAlways:
            print(".Authorized")
            //self.locationManager.startUpdatingLocation()
            
            break
            
            
        case .Denied:
            print(".Denied")
            break
            
        default:
            print("Unhandled authorization status")
            break
            
        }
    }
    
    func beginTrip() {
        distanceMoved = 0.0
        locations.removeAll(keepCapacity: false)
        self.locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                if self.locations.count > 0 {
                    distanceMoved += location.distanceFromLocation(self.locations.last!)
                    let userInfo = ["distance" : distanceMoved]
                    NSNotificationCenter.defaultCenter().postNotificationName("DISTANCE_UPDATE", object: nil, userInfo: userInfo)
                }
                self.locations.append(location)
            }
        }
    }

    func StopTrip(){
        locationManager.stopUpdatingLocation()
       
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print(error)
        
    }

}


