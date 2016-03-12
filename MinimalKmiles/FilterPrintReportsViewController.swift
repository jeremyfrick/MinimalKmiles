//
//  FilterPrintReportsViewController.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 3/6/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import UIKit
import CoreData

class FilterPrintReportsViewController: UITableViewController {

    let beginDatePickerRowIndex = 1
    let endingDatePickerRowIndex = 3
    let kDatePickerCellHeight: CGFloat = 164.0
    
    var beginDatePickerIsShowing = false
    var endingDatePickerIsShowing = false
    
    var managedObjectContext : NSManagedObjectContext!
    var coreDataStack: CoreDataStack!
    let printer = ReportPrinter()
    let quires = TripQueries()
    
    
    @IBOutlet weak var beginingDatePicker: UIDatePicker!
    @IBOutlet weak var endingDatePicker: UIDatePicker!
    @IBOutlet weak var weeksSegmentedControl: UISegmentedControl!
    @IBOutlet weak var monthsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var beginingDateLabel: UITextField!
    @IBOutlet weak var endingDateLabel: UITextField!
    
    var reportStartingDateFactor = 0
    var customReportStartingDate: NSDate!
    var customReportEndingDate: NSDate!
    var printedDataTest: String!
    
    let formatter = NSDateFormatter()
    
    override func viewDidLoad() {
        beginDatePickerIsShowing = false
        endingDatePickerIsShowing = false
        formatter.dateStyle = .MediumStyle
    }
    
    @IBAction func printReportButtonPressed(sender: AnyObject) {
        
        if weeksSegmentedControl.selected == true || monthsSegmentedControl.selected == true {
            printedDataTest = printer.BuildMultiTripReport(quires.getTripsForReport(managedObjectContext, numberofDays: reportStartingDateFactor))
        } else if (((customReportStartingDate != nil) && (customReportEndingDate != nil))) {
            printedDataTest = printer.BuildMultiTripReport(quires.getTripsForReport(managedObjectContext, startDate: customReportStartingDate, endDate: customReportEndingDate))
        }
           // let printedData = printer.BuildMultiTripReport(quires.getTripsForReport(managedObjectContext))
        
        let pic = UIPrintInteractionController.sharedPrintController()
        pic.showsPageRange = true
        let milageReport = UISimpleTextPrintFormatter(text: printedDataTest)
        milageReport.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0)
        pic.printFormatter = milageReport
        pic.presentAnimated(true, completionHandler: nil)
        
    }
    // MARK: - Segmented Controls
        
    @IBAction func weeksSegmentedControlPressed(sender: AnyObject) {
        
        monthsSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        weeksSegmentedControl.selected = true
        monthsSegmentedControl.selected = false
        beginingDateLabel.text = ""
        endingDateLabel.text = ""
        
        switch weeksSegmentedControl.selectedSegmentIndex {
        case 0:
            reportStartingDateFactor = -7
        case 1:
            reportStartingDateFactor = -14
        case 2:
            reportStartingDateFactor = -21
        default:
            reportStartingDateFactor = 0
        }
    }
    
    @IBAction func monthsSelectedSegmentedControl(sender: AnyObject) {
        
        weeksSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        monthsSegmentedControl.selected = true
        weeksSegmentedControl.selected = false
        beginingDateLabel.text = ""
        endingDateLabel.text = ""
        
        switch monthsSegmentedControl.selectedSegmentIndex {
        case 0:
            reportStartingDateFactor = -30
        case 1:
            reportStartingDateFactor = -90
        case 2:
            reportStartingDateFactor = -180
        default:
            reportStartingDateFactor = 0
        }

    }
    
    // MARK: - TableView
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight = self.tableView.rowHeight
        if (indexPath.section == 1 && indexPath.row == beginDatePickerRowIndex){
            rowHeight = beginDatePickerIsShowing ? kDatePickerCellHeight : 0.0
            self.beginingDatePicker.alpha = 0.0
        }else if (indexPath.section == 1 && indexPath.row == endingDatePickerRowIndex){
            rowHeight = self.endingDatePickerIsShowing ? kDatePickerCellHeight : 0.0
            self.endingDatePicker.alpha = 0.0
        }
        return rowHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1 && indexPath.row == 0){
            weeksSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            monthsSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            monthsSegmentedControl.selected = false
            weeksSegmentedControl.selected = false

            if (self.beginDatePickerIsShowing){
                hideBeginingDatePicker()
            }else {
                showBeginDatePickerCell()
            }
        }else if (indexPath.section == 1 && indexPath.row == 2){
            weeksSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            monthsSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            monthsSegmentedControl.selected = false
            weeksSegmentedControl.selected = false
            if (self.endingDatePickerIsShowing){
                hideEndingDatePickerCell()
            }else{
                showEndingDatePickerCell()
            }
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func determineStartDateForReport() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let today = NSDate()
        let dateComps = NSDateComponents()
        let daysToSubtract = -7
        dateComps.setValue(-7, forComponent: .Day)
        let startDate = calendar.dateByAddingUnit(.Day, value: daysToSubtract, toDate: today, options: NSCalendarOptions.init(rawValue: 0))
        print (startDate)
        print (today)
        return startDate!
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 91/255, green: 74/255, blue: 34/255, alpha: 1.0)
        header.textLabel!.textColor = UIColor(red: 195/255, green: 100/255, blue: 53/255, alpha: 1.0)
        header.alpha = 1.0
    }
    
    // MARK: - UIPickerCell
    
    @IBAction func BeginingDatePicked(sender: AnyObject) {
        
        customReportStartingDate = sender.date
        beginingDateLabel.text = formatter.stringFromDate(customReportStartingDate)
    }
    
    @IBAction func endingDatePicked(sender: AnyObject) {
        customReportEndingDate = sender.date
        endingDateLabel.text = formatter.stringFromDate(customReportEndingDate)
        
    }

    func showBeginDatePickerCell() {
        beginDatePickerIsShowing = true
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        beginingDatePicker.hidden = false
        self.beginingDatePicker.alpha = 0.0
        UIView.animateWithDuration(0.25, animations: {
            self.beginingDatePicker.alpha = 1.0
        })
    }
    
    func showEndingDatePickerCell() {
        endingDatePickerIsShowing = true
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        endingDatePicker.hidden = false
        self.endingDatePicker.alpha = 0.0
        UIView.animateWithDuration(0.25, animations: {
            self.endingDatePicker.alpha = 1.0
        })

    }
    
    func hideBeginingDatePicker() {
        beginDatePickerIsShowing = false
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.animateWithDuration(0.25, animations: {
            self.beginingDatePicker.alpha = 0.0
        })
        beginingDatePicker.hidden = true
    }
    
    func hideEndingDatePickerCell() {
        endingDatePickerIsShowing = false
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.animateWithDuration(0.25, animations: {
            self.endingDatePicker.alpha = 0.0
        })
        endingDatePicker.hidden = true
    }
}
