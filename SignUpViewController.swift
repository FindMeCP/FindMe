//
//  LoginViewController.swift
//  FindMe
//
//  Created by William Tong on 3/8/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var phoneText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUp(sender: AnyObject) {
        let newUser = PFUser()
        
        newUser.username = usernameText.text
        newUser.password = passwordText.text
        let phonenumber: String = phoneText.text!
        newUser["phone"] = storeAsPhone(phonenumber)
        if(phonenumber.characters.count==10){
            // call sign up function on the object
            newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("User Registered successfully")
                    self.performSegueWithIdentifier("signUpSegue", sender: nil)
                    // manually segue to logged in view
                }
            }
        }else{
            print("invalid phone number")
        }
        newUser["follow"]=""
        newUser["tracking"]=true
    }
    
    func storeAsPhone(phone: String)->String{
        let stringArray = phone.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let newString = stringArray.joinWithSeparator("")
        return newString
    }
    
}

