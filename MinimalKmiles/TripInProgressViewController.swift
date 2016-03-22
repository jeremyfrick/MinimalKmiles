//
//  TripInProgressViewController.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 5/27/15.
//  Copyright (c) 2015 Red Anchor Software. All rights reserved.
//

import UIKit
import CoreData


class TripInProgressViewController: UIViewController {

    let prefs = NSUserDefaults(suiteName:"group.RedAnchorSoftware.MinimalKmiles")!
 
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var unitOfMeasurementSwitch: UISegmentedControl!
    @IBOutlet weak var purposeOfTrip: UITextField!
    @IBOutlet weak var stopStartTripButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var currentTrip: Trip!
    var trips: [Trip]! = []
    var editTrip: Trip!
    var stack: CoreDataStack!
    var locationManager: CoreLocationController!
    var measurement: unitOfMeasurement!
    let converter = Converter()

    
    override func viewWillAppear(animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopStartTripButton.setImage(UIImage(named: "stopButton"), forState: .Normal)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TripInProgressViewController.distanceUpdated(_:)), name: "DISTANCE_UPDATE", object: nil)
        currentTrip = checkforTripInProgress()
        let measurementCheck = Int(currentTrip.miles)
        switch measurementCheck {
        case 1:
            self.unitOfMeasurementSwitch.selectedSegmentIndex = 1
            measurement = unitOfMeasurement.Kilometers
        case 0:
            self.unitOfMeasurementSwitch.selectedSegmentIndex = 0
            measurement = unitOfMeasurement.Miles
        default:
            break
            }
        purposeOfTrip.text = currentTrip.purpose
        navigationItem.title = currentTrip.purpose
        self.stopStartTripButton.enabled = true
    }
    
    func checkforTripInProgress() -> Trip {
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        let predicate = NSPredicate(format: "tripInProgress = 1")
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate

        do {
            try trips = stack.context.executeFetchRequest(fetchRequest) as! [Trip]
        } catch let error as NSError {
            print("Error: \(error)")
        }
        print([trips])
        return trips[0]
    

    }
    func clearAllInProgressTrips(){
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        let predicate = NSPredicate(format: "tripInProgress = 1")
        fetchRequest.predicate = predicate
        
        do {
            //let trip = Trip()
            let fetchedTrips = try stack.context.executeFetchRequest(fetchRequest)
            for oldtrip in fetchedTrips {
                (oldtrip as! Trip).tripInProgress = false
            }
        } catch let error as NSError {
            print("Error: \(error)")
        }
        do {
            try stack.context.save()
        } catch let error as NSError {
            print("Error: \(error)")
        }
    }

    
    func distanceUpdated(notification:NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String,Double>
        if let newDistance = userInfo["distance"]{
            currentTrip.rawdistance = newDistance
            distanceLabel.text = converter.convert(unitOfMeasurementSwitch.selectedSegmentIndex , distance: newDistance)
        }
    }

    @IBAction func unitOfMeasurementSelectionChanged(sender: AnyObject) {
        if (unitOfMeasurementSwitch.selectedSegmentIndex == 0){
            measurement = unitOfMeasurement.Miles
            distanceLabel.text = String.localizedStringWithFormat("%.1f",((currentTrip.rawdistance) / 1609.344))
            
        }else {
            measurement = unitOfMeasurement.Kilometers
            distanceLabel.text = String.localizedStringWithFormat("%.1f",((currentTrip.rawdistance) / 1000))
            
        }

    }
    
    @IBAction func startStopButtonPressed(sender: AnyObject) {
        let updatedTripInProgressStatus = currentlyTracking.No
        prefs.setInteger(updatedTripInProgressStatus.rawValue, forKey: "TripInProgress")
        locationManager.StopTrip()
        currentTrip.miles = Int16(measurement.rawValue)
        currentTrip.purpose = purposeOfTrip.text!
        currentTrip.distance = 0
        currentTrip.tripInProgress = false
        do {
            try stack.context.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        self.stopStartTripButton.enabled = false
        print("\(currentTrip)")
        clearAllInProgressTrips()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
