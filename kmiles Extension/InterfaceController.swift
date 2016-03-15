//
//  InterfaceController.swift
//  kmiles Extension
//
//  Created by Jeremy Frick on 3/12/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var tripControlButton: WKInterfaceButton!
    
    var tripInProgressStatus: currentlyTracking!
    let prefs = NSUserDefaults(suiteName:"group.RedAnchorSoftware.MinimalKmiles")
    var status: Int!
    
    
    override func awakeWithContext(context: AnyObject?) {
        if(WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        status = updateStatus()
        if let tripInProgressStatus = currentlyTracking(rawValue:status) {
            if tripInProgressStatus == currentlyTracking.Yes {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tripControlButton.setBackgroundImageNamed("stopButton")}
            }else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tripControlButton.setBackgroundImageNamed("goButton")}
            }
        }

    super.awakeWithContext(context)
    }
    
    func updateStatus()->Int {
        if WCSession.defaultSession().reachable == true {
            let requestValues = ["Message": 1]
            let session = WCSession.defaultSession()
            session.sendMessage(requestValues, replyHandler: {reply in
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 100 * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue()) {
                    self.status = reply["Message"] as! Int
                    print(reply["Message"])
                }
                self.status = reply["Message"] as! Int
                print(reply["Message"])
                }, errorHandler: {error in
                    print("Error: \(error)")
            })
        }else {
            print("NO GO")
        }
        if status == nil {
            return 1
        } else{
        return status
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        print(message["Message"])
        status = message["Message"] as! Int
        print("Status: \(status)")
        if let tripInProgressStatus = currentlyTracking(rawValue:status) {
            if tripInProgressStatus == currentlyTracking.Yes {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.tripControlButton.setBackgroundImageNamed("stopButton")}
                print("STOP")
            }else {
                print("Go")
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.tripControlButton.setBackgroundImageNamed("goButton")}
                
            }
            
        }
    }

    
    @IBAction func buttonPressed() {
        if let tripInProgressStatus = currentlyTracking(rawValue:status) {
            if tripInProgressStatus == currentlyTracking.Yes {
                status = 1
                dispatch_async(dispatch_get_main_queue()) {
                    self.tripControlButton.setBackgroundImageNamed("stopButton")}
                    if WCSession.defaultSession().reachable == true {
                        let requestValues = ["Message": 1]
                        let session = WCSession.defaultSession()
                        session.sendMessage(requestValues, replyHandler: {reply in
                                        }, errorHandler: {error in
                                            print("Error: \(error)")
                        })
                    }else {
                        print("NO GO")
                    }
            }else {
                status = 0
                dispatch_async(dispatch_get_main_queue()) {
                    self.tripControlButton.setBackgroundImageNamed("goButton")}
                if WCSession.defaultSession().reachable == true {
                    let requestValues = ["Message": 0]
                    let session = WCSession.defaultSession()
                    session.sendMessage(requestValues, replyHandler: {reply in
                        }, errorHandler: {error in
                            print("Error: \(error)")
                    })
                }else {
                    print("NO GO")

                
            }
        }

    }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to us
        super.willActivate()
        updateStatus()
        if let tripInProgressStatus = currentlyTracking(rawValue:status) {
            if tripInProgressStatus == currentlyTracking.Yes {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tripControlButton.setBackgroundImageNamed("stopButton")}
            }else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tripControlButton.setBackgroundImageNamed("goButton")}
            }
        }
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
