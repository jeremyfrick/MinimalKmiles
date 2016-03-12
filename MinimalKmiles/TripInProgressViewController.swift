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

    let userDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.RedAnchorSoftware.MinimalKmiles")!
    @IBOutlet weak var ReturnToListOfTripsButton: UIButton!
    @IBOutlet weak var currentMilageLabel: UILabel!
    @IBOutlet weak var purposeOfTrip: UITextField!
    @IBOutlet weak var unitOfMeasurementSwitch: UISegmentedControl!
    @IBOutlet weak var tripToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var startStopTripButton: UIBarButtonItem!
    @IBOutlet weak var printReportButton: UIBarButtonItem!
    
    var currentTrip: Trip!
    var tripStatus = String()
    var tripMeasurement = Int()
    var tripDistance = Double()
    var tripPurpose = String()
    var managedObjectContext : NSManagedObjectContext!
    var coreDataStack: CoreDataStack!

    
    override func viewWillAppear(animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        purposeOfTrip.text = currentTrip.purpose
        
//        tripStatus = userDefaults.stringForKey("Status")!
//        tripMeasurement = userDefaults.integerForKey("measurment")
//        tripDistance = userDefaults.doubleForKey("TripInProgress")
//        tripPurpose = userDefaults.stringForKey("purpose")!
        //self.purposeOfTripLabel.text = tripPurpose

        // Do any additional setup after loading the view.
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
