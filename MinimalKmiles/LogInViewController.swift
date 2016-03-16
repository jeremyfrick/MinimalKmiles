//
//  LogInViewController.swift
//  MinimalKmiles
//
//  Created by Jeremy Frick on 3/16/16.
//  Copyright © 2016 Red Anchor Software. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createInfoLabel: UILabel!
    
    let userNameKey = "batman"
    let passwordKey = "Hello Bruce!"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLogin(userName: String, password: String) -> Bool {
        if ((userName == userNameKey)&&(password == passwordKey)){
            return true
        } else {
            return false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func loginAction(sender: AnyObject) {
        if (checkLogin(self.usernameTextField.text!, password: self.passwordTextField.text!)) {
           self.performSegueWithIdentifier("dismissLogin", sender: self) 
        }
        
    }

}
