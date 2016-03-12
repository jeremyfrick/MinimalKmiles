//
//  editPopOverViewController.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 2/27/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import UIKit
import CoreData


class editPopOverViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tripPurposeTextBox: UITextField!
    @IBOutlet weak var measurementSgmentedControl: UISegmentedControl!
    @IBOutlet weak var tripNotes: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    var measurement: unitOfMeasurement!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dialogView.layer.cornerRadius = 8.0
        dialogView.layer.masksToBounds = true
        
        if trip != nil {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            tripPurposeTextBox.text = trip?.purpose
            tripNotes.text = trip?.notes
            measurementSgmentedControl.selectedSegmentIndex = Int(trip.miles)
        }
        
        tripNotes.delegate = self
        tripPurposeTextBox.delegate = self
    }
    
    // MARK: - UIControls
    
    @IBAction func measurementSelectionChanged(sender: AnyObject) {
        
        if trip != nil {
            if (measurementSgmentedControl.selectedSegmentIndex == 0){
                measurement = unitOfMeasurement.Miles
                trip!.miles = Int16(measurement.rawValue)
            }else {
                measurement = unitOfMeasurement.Kilometers
                trip!.miles = Int16(measurement.rawValue)
            }
        }

    }
    
    @IBAction func saveChangedButtonPressed(sender: AnyObject) {
        trip!.purpose = tripPurposeTextBox.text!
        trip!.notes = tripNotes.text
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelEditButtonPressed(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Scene Navigation
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed() {
            NSNotificationCenter.defaultCenter().postNotificationName("TRIP_UPDATE", object: trip)
        }
    }
    
    // MARK: - Keyboard Control helpers
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches as Set<UITouch>, withEvent: event)
    }
    
        func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
        
    func textViewDidEndEditing(textView: UITextView) {
        trip.notes = tripNotes.text
        textView.resignFirstResponder()
    }
}
