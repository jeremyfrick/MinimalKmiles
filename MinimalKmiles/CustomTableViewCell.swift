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
    @IBOutlet var tripTitle : UILabel!
    @IBOutlet var tripDate : UILabel!
    @IBOutlet var tripDistance: UILabel!
    @IBOutlet var tripMeasurment: UILabel!
    @IBOutlet weak var tripNotesButton: UIButton!
    
    
}
