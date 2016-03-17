//
//  LogInViewController.swift
//  MinimalKmiles
//
//  Created by Jeremy Frick on 3/16/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import UIKit
import LocalAuthentication
import Security

class LogInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createInfoLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var touchIDButton: UIButton!
    @IBOutlet weak var onepasswordSigninButton: UIButton!
    
    
    let MyKeychainWrapper = KeychainWrapper()
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    let prefs = NSUserDefaults(suiteName:"group.RedAnchorSoftware.MinimalKmiles")!
    var context = LAContext()
    let MyOnePassword = OnePasswordExtension()
    var has1PasswordLogin = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        
        let hasLogin = prefs.boolForKey("hasLoginKey")
        
        if hasLogin {
            loginButton.setTitle(("Login"), forState: UIControlState.Normal)
            loginButton.tag = loginButtonTag
            createInfoLabel.hidden = true
            onepasswordSigninButton.enabled = true
        } else {
            loginButton.setTitle("Create", forState: UIControlState.Normal)
            loginButton.tag = createLoginButtonTag
            createInfoLabel.hidden = false
            onepasswordSigninButton.enabled = false
        }
        if let storedUsername = prefs.valueForKey("username") as? String {
            usernameTextField.text = storedUsername as String
        }
        
        touchIDButton.hidden = true
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: nil) {
            touchIDButton.hidden = false
           // self.touchIDLoginAction(touchIDButton)
        }
        
        onepasswordSigninButton.hidden = true
        let has1Password = prefs.boolForKey("has1PassLogin")
        
        if MyOnePassword.isAppExtensionAvailable() {
            onepasswordSigninButton.hidden = false
            if has1Password {
                onepasswordSigninButton.setImage(UIImage(named: "onepassword-button"), forState: .Normal)
            } else {
                onepasswordSigninButton.setImage((UIImage(named: "onepassword-button-green")), forState: .Normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLogin(username: String, password: String) -> Bool {
        if password == MyKeychainWrapper.myObjectForKey("v_Data") as? String &&
            username == prefs.valueForKey("username") as! String? {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func canUse1Password(sender: UIButton) {
        if prefs.objectForKey("has1PassLogin") != nil {
            self.findLoginFrom1Password(self)
        } else {
            self.saveLoginTo1Password(self)
        }
    }
    func saveLoginTo1Password(sender: AnyObject){
    
    let newLoginDetails : NSDictionary = [
      AppExtensionTitleKey: "MinimalKmiles",
      AppExtensionUsernameKey: self.usernameTextField.text!,
      AppExtensionPasswordKey: self.passwordTextField.text!,
      AppExtensionNotesKey: "Saved with the MinimalKmiles app",
      AppExtensionSectionTitleKey: "MinimalKmiles app",
    ]
    
    let passwordGenerationOptions : NSDictionary = [
      AppExtensionGeneratedPasswordMinLengthKey: "6",
      AppExtensionGeneratedPasswordMaxLengthKey: "50"
    ]
    
    MyOnePassword.storeLoginForURLString("MinimalKmiles.login", loginDetails: newLoginDetails as! [String : String], passwordGenerationOptions: passwordGenerationOptions as [NSObject : AnyObject], forViewController: self, sender: sender){ (loginDict : [NSObject : AnyObject]?, error : NSError?) -> Void in
        
        if loginDict == nil {
//          if error!.code != AppExtensionErrorCodeCancelledByUser {
//            print("Error invoking 1Password App Extension for find login: \(error)")

          return
        }
        
        let foundUsername = loginDict!["username"] as! String
        let foundPassword = loginDict!["password"] as! String
        
        if self.checkLogin(foundUsername, password: foundPassword) {
          
          self.performSegueWithIdentifier("dismissLogin", sender: self)
          
        } else {
          
          let alertView = UIAlertController(title: "Error", message: "The info in 1Password is incorrect" as String, preferredStyle:.Alert)
          let okAction = UIAlertAction(title: "Darn!", style: .Default, handler: nil)
          alertView.addAction(okAction)
          self.presentViewController(alertView, animated: true, completion: nil)
          
        }
        
        if self.prefs.objectForKey("username") != nil {
          self.prefs.setValue(self.usernameTextField.text, forKey: "username")
        }
        
        self.prefs.setBool(true, forKey: "has1PassLogin")
        }
  }
    
    @IBAction func findLoginFrom1Password(sender: AnyObject) {
        MyOnePassword.findLoginForURLString("MinimalKmiles.login", forViewController: self, sender: sender, completion: {(loginDict: [NSObject:AnyObject]?, error:NSError?) -> Void in
            
            if loginDict == nil {
//                if error.code != AppExtensionErrorCodeCancelledByUser {
//                    print("Error invoking 1Password app extension for find login: \(error)")
//                }
                return
            }
            
            if self.prefs.objectForKey("username") == nil {
                self.prefs.setValue(loginDict![AppExtensionUsernameKey], forKey: "username")
            }
            
            let foundUsername = loginDict!["username"] as! String
            let foundPassword = loginDict!["password"] as! String
            
            if self.checkLogin(foundUsername, password: foundPassword) {
                self.performSegueWithIdentifier("dismissLogin", sender: self)
            } else {
                let alertview = UIAlertController(title: "Error", message: "The user info in 1Password is incorrect", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "ok", style: .Default, handler: nil)
                alertview.addAction(okAction)
                self.presentViewController(alertview, animated: true, completion: nil)
            }
        })
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
        if (usernameTextField.text == "" || passwordTextField.text == ""){
            let alertView = UIAlertController(title: "Login Problem", message: "Missing username or pasword." as String, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Denied Entry", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
            return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if sender.tag == createLoginButtonTag {
            
            let hasLoginKey = prefs.boolForKey("hasLoginKey")
            if hasLoginKey == false {
                prefs.setValue(self.usernameTextField.text, forKey: "username")
            }
            MyKeychainWrapper.mySetObject(passwordTextField.text, forKey: kSecValueData)
            MyKeychainWrapper.writeToKeychain()
            prefs.setBool(true, forKey: "hasLoginKey")
            loginButton.tag = loginButtonTag
            
            shouldPerformSegueWithIdentifier("dismisslogin", sender: self)
        } else if sender.tag == loginButtonTag {
            if checkLogin(usernameTextField.text!, password: passwordTextField.text!) {
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
