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
    let printer = ReportPrinter()
    

    
    override func viewWillAppear(animated: Bool) {
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
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
        shareButton.enabled = false
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
        shareButton.enabled = true
        print("\(currentTrip)")
        clearAllInProgressTrips()
    }

    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        var printData = ("","")
        switch unitOfMeasurementSwitch.selectedSegmentIndex {
        case 0:
            printData = printer.buildShareReport("Miles", distanceTravled: distanceLabel.text!, purposeOfTrip: purposeOfTrip.text!)
        case 1:
            printData = printer.buildShareReport("km", distanceTravled: distanceLabel.text!, purposeOfTrip: purposeOfTrip.text!)
        default:
            break
        }
        let printerData = UISimpleTextPrintFormatter(text:printData.0 as String)
        printerData.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0)
        
        let itemsToShare = [printData.1,printerData]
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        let popoverVC = activityVC as UIViewController
        popoverVC.modalPresentationStyle = .Popover
        
        let popoverController = popoverVC.popoverPresentationController
        popoverController?.sourceView = toolbar as UIView
        popoverController?.sourceRect = toolbar.bounds
        popoverController?.permittedArrowDirections = .Any
        presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    func shareTextImageAndURL(sharingText sharingText: String?, sharingImage: UIImage?, sharingURL: NSURL?) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
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
