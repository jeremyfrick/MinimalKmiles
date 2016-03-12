//
//  ViewNotesController.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 3/1/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewNotesController: UIViewController {

    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var tripNotesTextView: UITextView!
    var selectedTrip: Trip!
    
    
    override func viewDidLoad() {
        dialogView.layer.cornerRadius = 8.0
        dialogView.layer.masksToBounds = true
        tripNotesTextView.text = selectedTrip.notes
    }
    
    @IBAction func closeViewNotesButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
