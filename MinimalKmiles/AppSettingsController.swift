//
//  AppSettingsController.swift
//  MinimalKmiles
//
//  Created by Jeremy Frick on 3/16/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import UIKit

class AppSettingsController: UITableViewController {
    
    @IBOutlet weak var touchIdSwitch: UISwitch!
    @IBOutlet weak var defaultMeasurementSegmentControl: UISegmentedControl!
    
    
    let prefs = NSUserDefaults(suiteName: "group.RedAnchorSoftware.MinimalKmiles")!
    var touchIdEnabled : Bool!
    var preferredMeasurement: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touchIdEnabled = prefs.boolForKey("touchID")
        preferredMeasurement = prefs.integerForKey("measurment")
        
        if touchIdEnabled! {
            touchIdSwitch.setOn(true, animated: true)
        } else{
            touchIdSwitch.setOn(false, animated: true)
        }
        
        defaultMeasurementSegmentControl.selectedSegmentIndex = preferredMeasurement
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func TouchIDSettingChange(sender: UISwitch) {
        if touchIdSwitch.on {
            prefs.setBool(true, forKey: "touchID")
        } else {
            prefs.setBool(false, forKey: "touchID")
        }
        
        
    }

    @IBAction func measurementSelectionChange(sender: UISegmentedControl) {
        if (defaultMeasurementSegmentControl.selectedSegmentIndex == 0){
            prefs.setInteger(defaultMeasurementSegmentControl.selectedSegmentIndex, forKey: "measurment")
        }else {
            prefs.setInteger(defaultMeasurementSegmentControl.selectedSegmentIndex, forKey: "measurment")
        }
    }
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 91/255, green: 74/255, blue: 34/255, alpha: 1.0)
        header.textLabel!.textColor = UIColor(red: 195/255, green: 100/255, blue: 53/255, alpha: 1.0)
        header.alpha = 1.0
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
