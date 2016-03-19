//
//  ViewTripsControllerTableViewController.swift
//  MinimalMiles
//
//  Created by Jeremy Frick on 9/27/14.
//  Copyright (c) 2014 Red Anchor Software. All rights reserved.
//

import UIKit
import CoreData

class ViewTripsControllerTableViewController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var measurementLabel: UILabel!
    @IBOutlet weak var TripInProgressButton: UIButton!
    
    var coreDataStack: CoreDataStack!
    var trips: [Trip]! = []
    var currentTrip: Trip!
    var managedContext: NSManagedObjectContext!
    var locationManager: CoreLocationController!
    var FetchResultsCon: NSFetchedResultsController!
    var resultSearchController = UISearchController(searchResultsController: nil)
    let prefs = NSUserDefaults(suiteName: "group.RedAnchorSoftware.MinimalKmiles")!
    let printer = ReportPrinter()
    let quires = TripQueries()
    var isAuthenticated = false
    var didReturnFromBackground = false
    var touchIdEnabled = false
    var tripInProgress = 1
    var measurement: unitOfMeasurement!
    
    @IBOutlet weak var LogoutButton: UIBarButtonItem!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        fetch(FetchResultsCon)
        tableView.reloadData()
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.placeholder = "Purpose of trip"
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.resultSearchController.searchBar.barTintColor = UIColor(red: 91/255, green: 74/255, blue: 34/255, alpha: 1.0)
        self.resultSearchController.searchBar.tintColor = UIColor(red: 195/255, green: 100/255, blue: 53/255, alpha: 1.0)
        self.resultSearchController.searchBar.translucent = true
        self.resultSearchController.searchBar.showsCancelButton = true
        self.resultSearchController.searchBar.autocapitalizationType = .None
        self.resultSearchController.searchBar.delegate = self
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        self.navigationController!.navigationBar.translucent = true
        self.navigationItem.title = "Trip Log"
    }
    
    override func viewDidAppear(animated: Bool) {
        touchIdEnabled = prefs.boolForKey("touchID")
        
        if touchIdEnabled{
        super.viewDidAppear(false)
        self.showLoginView()
        } else {
            tripInProgress = prefs.integerForKey("TripInProgress")
            if let tripInProgressStatus = currentlyTracking(rawValue: tripInProgress) {
                if tripInProgressStatus == currentlyTracking.Yes {
                    self.performSegueWithIdentifier("tripInProgress", sender: self)
                } else {
                    super.viewDidAppear(true)
                }
            }

        }
        tripInProgress = prefs.integerForKey("TripInProgress")
        if let tripInProgressStatus = currentlyTracking(rawValue: tripInProgress) {
            if tripInProgressStatus == currentlyTracking.Yes {
                self.performSegueWithIdentifier("tripInProgress", sender: self)
        
            } else {
                super.viewDidAppear(true)
            }
        }
    }
    
    override func viewDidLoad() {
        touchIdEnabled = prefs.boolForKey("touchID")
        
        if touchIdEnabled{
            view.alpha = 0
        } else {
            view.alpha = 1
        }
        
        super.viewDidLoad()
        FetchResultsCon = getFetchResultsCon()
        fetch(FetchResultsCon)
        
        self.refreshControl?.addTarget(self, action: #selector(ViewTripsControllerTableViewController.refreshTable(_:)), forControlEvents: UIControlEvents.ValueChanged)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewTripsControllerTableViewController.appWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewTripsControllerTableViewController.appDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        
        tableView.estimatedRowHeight = 46.0
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        isAuthenticated = true
        view.alpha = 1.0
    }
    
    func appWillResignActive(notification : NSNotification) {
        touchIdEnabled = prefs.boolForKey("touchID")
        if touchIdEnabled {
        view.alpha = 0
        isAuthenticated = false
        didReturnFromBackground = true
        }
    }
    
    func appDidBecomeActive(notification : NSNotification) {
        touchIdEnabled = prefs.boolForKey("touchID")
        if didReturnFromBackground && touchIdEnabled{
            self.showLoginView()
        }
    }
    func showLoginView() {
        
        if !isAuthenticated {
            
            self.performSegueWithIdentifier("loginView", sender: self)
        }
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        
        isAuthenticated = false
        self.performSegueWithIdentifier("loginView", sender: self)
    }
    

    @IBAction func addTripButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("newTrip", sender: self)
    }

    
    // MARK: - TableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = FetchResultsCon.sections![section].numberOfObjects
        if numberOfRowsInSection < 1 {
            navigationItem.rightBarButtonItems![1].enabled = false
        } else {
            navigationItem.rightBarButtonItems![1].enabled = true
        }
        return numberOfRowsInSection
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomTableViewCell
        let trip = self.FetchResultsCon.objectAtIndexPath(indexPath) as? Trip
        dispatch_async(dispatch_get_main_queue()){
            cell.tripTitle.text = trip!.purpose
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            cell.tripDate.text = formatter .stringFromDate(trip!.timestamp)
            
            let unitOfMeasurment = trip?.miles
            self.measurement = unitOfMeasurement(rawValue: Int(unitOfMeasurment!))!
            
            if self.measurement == unitOfMeasurement.Kilometers {
                cell.tripMeasurment.text = "km"
                cell.tripDistance.text = String.localizedStringWithFormat("%.1f",(trip!.rawdistance / 1000))
            } else {
                cell.tripMeasurment.text = "mi"
                cell.tripDistance.text = String.localizedStringWithFormat("%.1f",(trip!.rawdistance / 1609.344))
            }
            if trip?.notes != "" {
                    cell.tripNotesButton.setImage(UIImage(named: "NoteBook"), forState: UIControlState.Normal)
                    cell.tripNotesButton.enabled = true
                } else {
                     cell.tripNotesButton.enabled = false
                }
            
            }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
        
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let tripToRemove = self.FetchResultsCon.objectAtIndexPath(indexPath) //trips![indexPath.row]
            managedContext.deleteObject(tripToRemove as! NSManagedObject)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save: \(error)")
        }
            fetch(FetchResultsCon)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func onTextSizeChange(notification: NSNotification) {
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetch(frcToFetch: NSFetchedResultsController){
        do {
            try frcToFetch.performFetch()
        } catch {
            return
        }
    }
    
    func fetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Trip")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
        
    }
    
    func getFetchResultsCon() -> NSFetchedResultsController {
        FetchResultsCon = NSFetchedResultsController(fetchRequest: fetchRequest(), managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
       
        return FetchResultsCon
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text!
        let trimmedSearchString = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if !trimmedSearchString.isEmpty {
            let predicate = NSPredicate(format: "(purpose CONTAINS [cd] %@)", trimmedSearchString)
            
            FetchResultsCon.fetchRequest.predicate = predicate
        }
        else {
            FetchResultsCon = getFetchResultsCon()
        }
        
            self.fetch(self.FetchResultsCon)
            self.tableView.reloadData()
    }
    
    func refreshTable(refreshCOntrol: UIRefreshControl) {
        self.fetch(self.FetchResultsCon)
        refreshControl?.endRefreshing()
    }
    // MARK: - Scene Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "tripViewEdit" {
            let editTripVC = segue.destinationViewController as! TripViewEditViewController
            let cell = sender as! UITableViewCell
                if let selectedIndex = tableView.indexPathForCell(cell) {
                    let trip = self.FetchResultsCon.objectAtIndexPath(selectedIndex)
                    editTripVC.trip = trip as! Trip
                    editTripVC.managedObjectContext = managedContext
                    editTripVC.coreDataStack = coreDataStack
                }
        }

        else if segue.identifier == "filterReports" {
                let reportsVC = segue.destinationViewController as! FilterPrintReportsViewController
                        reportsVC.managedObjectContext = managedContext
                        reportsVC.coreDataStack = coreDataStack
            }
            
        else if segue.identifier == "showTripNotes" {
            let viewNotesVC = segue.destinationViewController as! ViewNotesController
            if sender.isKindOfClass(UIButton) {
                let btnPos: CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
                let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(btnPos)!
                let trip = self.FetchResultsCon.objectAtIndexPath(indexPath)
                viewNotesVC.selectedTrip = trip as! Trip
            }

        }else if segue.identifier == "newTrip" {
                let newTripVC = segue.destinationViewController as! NewTripViewController
                        newTripVC.managedObjectContext = managedContext
                        newTripVC.coreDataStack = coreDataStack
                        newTripVC.locationManager = locationManager
                        newTripVC.navigationItem.rightBarButtonItem?.enabled = true

        } else if segue.identifier == "tripInProgress" {
            let inProgressTripVC = segue.destinationViewController as! TripInProgressViewController
            inProgressTripVC.managedObjectContext = managedContext
            inProgressTripVC.coreDataStack = coreDataStack
            inProgressTripVC.locationManager = locationManager
            let index = trips.count - 1
            inProgressTripVC.currentTrip = trips[index]
            //inProgressTripVC.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
}