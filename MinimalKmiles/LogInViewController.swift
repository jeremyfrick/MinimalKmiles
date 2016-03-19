//
//  LogInViewController.swift
//  MinimalKmiles
//
//  Created by Jeremy Frick on 3/16/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import UIKit
import LocalAuthentication

class LogInViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createInfoLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var touchIDButton: UIButton!
       
    
    let MyKeychainWrapper = KeychainWrapper()
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    let prefs = NSUserDefaults(suiteName:"group.RedAnchorSoftware.MinimalKmiles")!
    var context = LAContext()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        
        let hasLogin = prefs.boolForKey("hasLoginKey")
        
        if hasLogin {
            loginButton.setTitle(("Login"), forState: UIControlState.Normal)
            loginButton.tag = loginButtonTag
            createInfoLabel.hidden = true
        } else {
            loginButton.setTitle("Create", forState: UIControlState.Normal)
            loginButton.tag = createLoginButtonTag
            createInfoLabel.hidden = false
        }

        touchIDButton.hidden = true
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: nil) {
            touchIDButton.hidden = false
           // self.touchIDLoginAction(touchIDButton)
        }
    }
    
            override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLogin(passcode: String) -> Bool {
        if passcode == MyKeychainWrapper.myObjectForKey("v_Data") as! String {
            return true
        } else {
            return false
        }
    }
    
      
    @IBAction func touchIDLoginAction(sender: UIButton) {
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Logging in with TouchID", reply: {(success : Bool, error : NSError?) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    if success {
                        self.performSegueWithIdentifier("dismissLogin", sender: self)
                    }
                    if error != nil {
                        
                        var message : String
                        var showAlert: Bool
                        
                        switch(error!.code) {
                        
                        case LAError.AuthenticationFailed.rawValue:
                            message = "There was a problem verifying your identity."
                            showAlert = true
                        case LAError.UserCancel.rawValue:
                            message = "You canceled the identifiacation process."
                            showAlert = true
                        case LAError.UserFallback.rawValue:
                            message = "You pressed password."
                            showAlert = true
                        default:
                            showAlert = true
                            message = "TouchID may not be configured."
                        }
                        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                        alertView.addAction(okAction)
                        if showAlert {
                            self.presentViewController(alertView, animated: true, completion: nil)
                        }
                    }
                })
        })
        } else {
            let alertView = UIAlertController(title: "Error", message: "TouchID not available.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }

    @IBAction func loginAction(sender: AnyObject) {
        if (passwordTextField.text == ""){
            let alertView = UIAlertController(title: "Login Problem", message: "Missing passcode." as String, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Denied Entry", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
            return
        }
        
        passwordTextField.resignFirstResponder()
        
        if sender.tag == createLoginButtonTag {
            
            let hasLoginKey = prefs.boolForKey("hasLoginKey")
            MyKeychainWrapper.mySetObject(passwordTextField.text, forKey: kSecValueData)
            MyKeychainWrapper.writeToKeychain()
            prefs.setBool(true, forKey: "hasLoginKey")
            loginButton.tag = loginButtonTag
            
            shouldPerformSegueWithIdentifier("dismisslogin", sender: self)
        } else if sender.tag == loginButtonTag {
            if checkLogin(passwordTextField.text!) {
                performSegueWithIdentifier("dismissLogin", sender: self)
            } else {
              let alertView = UIAlertController(title: "Login Issue", message: "Wrong username or password" as String, preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "Login Problem", style: .Default, handler: nil)
                alertView.addAction(okAction)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }
    }

}
