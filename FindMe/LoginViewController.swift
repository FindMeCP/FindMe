//
//  LoginViewController.swift
//  FindMe
//
//  Created by William Tong on 3/8/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var usernameText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(usernameText.text!, password: passwordText.text!){(user: PFUser?, NSError)-> Void in
            if user != nil {
                print("you're logged in!")
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }
        }
    }
    
    

}
