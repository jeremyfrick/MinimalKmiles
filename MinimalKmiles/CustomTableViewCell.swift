//
//  CustomTableViewCell.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 2/21/15.
//  Copyright (c) 2015 Red Anchor Software. All rights reserved.
//

import UIKit


class CustomTableViewCell: UITableViewCell
{
    
    enum unitOfMeasurement: Int {
        case Miles = 0
        case Kilometers = 1
    }

    var measurement: unitOfMeasurement!
    
    var appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let queue = (UIApplication.sharedApplication().delegate as! AppDelegate).tableSetupQueue
    var trip: Trip?
        {
        didSet
        {
            let op = NSBlockOperation  { () -> Void in
        
                self.updateTripInfo()
            }
            queue?.addOperation(op)
        }
    }
    @IBOutlet var tripTitle : UILabel!
    @IBOutlet var tripDate : UILabel!
    @IBOutlet var tripDistance: UILabel!
    @IBOutlet var tripMeasurment: UILabel!
    @IBOutlet weak var tripNotesButton: UIButton!
    
    
    func updateTripInfo()
    {
        if trip != nil
        {
            tripTitle.text = trip!.purpose
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            let dateString : String = formatter .stringFromDate(trip!.timestamp)
            tripDate.text = dateString
            let test = trip?.miles
            measurement = unitOfMeasurement(rawValue: Int(test!))!

            if measurement == unitOfMeasurement.Kilometers {
                self.tripMeasurment.text = "km"
                self.tripDistance.text = String.localizedStringWithFormat("%.1f",(trip!.rawdistance / 1000))
            } else {
                self.tripMeasurment.text = "mi"
                self.tripDistance.text = String.localizedStringWithFormat("%.1f",(trip!.rawdistance / 1609.344))
            }
            if trip?.notes != "" {
                tripNotesButton.setImage(UIImage(named: "NoteBook"), forState: UIControlState.Normal)
                tripNotesButton.enabled = true

            }else {
               // tripNotesButton.enabled = false
            }

            
        }
    }
}
