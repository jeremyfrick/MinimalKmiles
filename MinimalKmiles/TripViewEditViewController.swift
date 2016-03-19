//
//  tripViewEditViewController.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 2/11/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TripViewEditViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var editToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tripNotes: UITextView!
    
    
    var managedObjectContext : NSManagedObjectContext!
    var coreDataStack: CoreDataStack!
    var trip: Trip!
    let converter = Converter()
    let printer = ReportPrinter()
    let prefs = NSUserDefaults(suiteName:"group.RedAnchorSoftware.MinimalKmiles")!
    var keyboardIsShowing: Bool!
    var keyboardFrame: CGRect!
    var kPreferredTextFieldToKeyboardOffset: CGFloat = 20.0
    var activeTextView: UIView!
    var updatedInfo: Trip?
    
    var measurement: unitOfMeasurement!
    
    override func viewDidLoad() {
        
        if trip != nil {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            dateLabel.text = formatter .stringFromDate((trip?.timestamp)!)
            purposeLabel.text = trip?.purpose
            distanceLabel.text = converter.convertFormatted(Int((trip?.miles)!), distance: (trip?.rawdistance)!)
            tripNotes.text = trip?.notes
            tripNotes.editable = false
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TripViewEditViewController.tripInfoUpdated(_:)), name: "TRIP_UPDATE", object: trip)
        navigationItem.title = trip?.purpose
    }
    
    // MARK: - ToolBar Buttons
    
    @IBAction func shareButtonPressed(sender: AnyObject){
        
        let purpose = self.purposeLabel.text
        var printData = ("","")
        if let test = unitOfMeasurement(rawValue: Int((trip?.miles)!)) {
            switch test {
            case .Miles:
                printData = printer.buildShareReport("Miles", distanceTravled: "50", purposeOfTrip: purpose!)
            case .Kilometers:
                printData = printer.buildShareReport("kilometers", distanceTravled: "50", purposeOfTrip: purpose!)
            }
        }
        let printerData = UISimpleTextPrintFormatter(text:printData.0 as String)
        printerData.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0)
        
        let itemsToShare = [printData.1,printerData]
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        let popoverVC = activityVC as UIViewController
        popoverVC.modalPresentationStyle = .Popover
        
        let popoverController = popoverVC.popoverPresentationController
        popoverController?.sourceView = editToolBar as UIView
        popoverController?.sourceRect = editToolBar.bounds
        popoverController?.permittedArrowDirections = .Any
        presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    // MARK: - UI Update Logic
    
    func tripInfoUpdated(notification:NSNotification){
        updatedInfo = (notification.object as? Trip)
        print(updatedInfo)
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        dateLabel.text = formatter .stringFromDate(updatedInfo!.timestamp)
        purposeLabel.text = updatedInfo!.purpose
        distanceLabel.text = converter.convertFormatted(Int(updatedInfo!.miles), distance: (updatedInfo!.rawdistance))
        tripNotes.text = updatedInfo!.notes
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
    
    // MARK: - Scene Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editTripInfo" {
            let editTripVC = segue.destinationViewController as! editPopOverViewController
                editTripVC.trip = trip
                editTripVC.managedObjectContext = managedObjectContext
                editTripVC.coreDataStack = coreDataStack
        }
    }
}
