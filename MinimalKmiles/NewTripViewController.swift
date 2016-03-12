//
//  NewTripViewController.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 2/25/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MessageUI

class NewTripViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var measurementSegment: UISegmentedControl!
    @IBOutlet weak var purposeTextBox: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var shareCurrentTripButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var stopStartButton: UIButton!
    
    var tripPurpose: String!
    var managedObjectContext: NSManagedObjectContext!
    var coreDataStack: CoreDataStack!
    var locationManager: CoreLocationController!
    var milageReport: UISimpleTextPrintFormatter!
    let prefs = NSUserDefaults(suiteName:"group.RedAnchorSoftware.MinimalKmiles")!
    var distance: Float!
    var trip: Trip?
    var currentTrip: Trip?
    var keyboardIsShowing: Bool!
    var keyboardFrame: CGRect!
    var kPreferredTextFieldToKeyboardOffset: CGFloat = 20.0
    var activeTextView: UIView!
    let printer = ReportPrinter()
    let quires = TripQueries()
    let converter = Converter()
    var tripInProgress: currentlyTracking!
    var measurement: unitOfMeasurement!
    var mainButtonStatus: tripStatus!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purposeTextBox.delegate = self
        shareCurrentTripButton.enabled = false
        navigationItem.rightBarButtonItem?.enabled = false
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewTripViewController.distanceUpdated(_:)), name: "DISTANCE_UPDATE", object: nil)
        
        let test = prefs.integerForKey("TripInProgress")
        if let tripInProgressStatus = currentlyTracking(rawValue: test) {
            if tripInProgressStatus == currentlyTracking.Yes {
                locationManager.StopTrip()
                let updatedTripInProgressStatus = currentlyTracking.No
                prefs.setInteger(updatedTripInProgressStatus.rawValue, forKey: "TripInProgress")
                self.viewWillAppear(true)
            }
        }
        
        if let measurementCheck = prefs.objectForKey("measurement"){
            measurementSegment.selectedSegmentIndex = measurementCheck as! Int
        } else {
            measurementSegment.selectedSegmentIndex = 0
            measurement = unitOfMeasurement.Miles
            
        }
    }
    
    func distanceUpdated(notification:NSNotification) {
        let userInfo = notification.userInfo as! Dictionary<String,Double>
        if let newDistance = userInfo["distance"]{
            trip?.rawdistance = newDistance
            distanceLabel.text = converter.convert(measurement.rawValue , distance: newDistance)
        }
    }
    
    // MARK: - UI Controls
    
    @IBAction func startStopButtonPressed(sender: AnyObject) {
        if let tripInProgressStatus = currentlyTracking(rawValue: prefs.objectForKey("TripInProgress") as! Int) {
            switch tripInProgressStatus {
            case .No:
                let updatedTripInProgressStatus = currentlyTracking.Yes
                prefs.setInteger(updatedTripInProgressStatus.rawValue, forKey: "TripInProgress")
                shareCurrentTripButton.enabled = false
                stopStartButton.setImage(UIImage(named: "stopButton"), forState: .Normal)
                let tripEnitity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: managedObjectContext)
                trip = Trip(entity: tripEnitity!, insertIntoManagedObjectContext: managedObjectContext)
                trip!.timestamp = NSDate()
                locationManager.beginTrip()
                
            case .Yes:
                let updatedTripInProgressStatus = currentlyTracking.No
                prefs.setInteger(updatedTripInProgressStatus.rawValue, forKey: "TripInProgress")
                locationManager.StopTrip()
                trip!.miles = Int16(measurement.rawValue)
                trip!.purpose = purposeTextBox.text!
                trip!.distance = 0
                do {
                    try managedObjectContext.save()
                } catch let error as NSError {
                    print("error: \(error.localizedDescription)")
                }
                shareCurrentTripButton.enabled = true
                UIView.animateWithDuration(5.0, delay: 0.0, options: .TransitionCrossDissolve, animations: {
                    self.stopStartButton.setImage(UIImage(named: "goButton"), forState: .Normal)
                    },
                                           completion: nil)
            }
        }

    }
    
    
    @IBAction func tripMeasurementSelection(sender: AnyObject) {
        
        if trip != nil {
            if (measurementSegment.selectedSegmentIndex == 0){
                measurement = unitOfMeasurement.Miles
                distanceLabel.text = String.localizedStringWithFormat("%.1f",((trip?.rawdistance)! / 1609.344))
                
            }else {
                measurement = unitOfMeasurement.Kilometers
                distanceLabel.text = String.localizedStringWithFormat("%.1f",((trip?.rawdistance)! / 1000))
                
            }
        }else {
            if (measurementSegment.selectedSegmentIndex == 0){
                measurement = unitOfMeasurement.Miles
                prefs.setInteger(measurement.rawValue, forKey: "measurment")
                
            }else {
                
                measurement = unitOfMeasurement.Miles
                prefs.setInteger(measurement.rawValue, forKey: "measurment")
            }
        }

    }
    
    //MARK: - ToolBar Buttons
    
       @IBAction func shareCurrentTripButtonPressed(sender: AnyObject) {

        var printData = ("","")
        switch measurementSegment.selectedSegmentIndex {
        case 0:
            printData = printer.buildShareReport("Miles", distanceTravled: distanceLabel.text!, purposeOfTrip: purposeTextBox.text!)
        case 1:
            printData = printer.buildShareReport("kilometers", distanceTravled: distanceLabel.text!, purposeOfTrip: purposeTextBox.text!)
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
        popoverController?.sourceView = toolBar as UIView
        popoverController?.sourceRect = toolBar.bounds
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
    
    //  MARK: - Scene Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    // MARK: - Textfield Handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches as Set<UITouch>, withEvent: event)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextView = textField
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        let purposeText = purposeTextBox.text
        prefs.setObject(purposeText, forKey: "purpose")
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        
        textField.resignFirstResponder()
        return true
    }
}