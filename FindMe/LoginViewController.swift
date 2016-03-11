//
//  LoginViewController.swift
//  FindMe
//
//  Created by William Tong on 3/8/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    @IBAction func signUp(sender: AnyObject) {
        let newUser = PFUser()
        
        newUser.username = usernameText.text
        newUser.password = passwordText.text
        
        // call sign up function on the object
        newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("User Registered successfully")
                self.performSegueWithIdentifier("loginSegue", sender: nil)
                // manually segue to logged in view
            }
        }
        
        
    }
    
    

}
