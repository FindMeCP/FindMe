//
//  SignUpViewController.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UIPopoverControllerDelegate {
    
    var user: PFUser = PFUser.current()!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var phoneText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func createNewUser() {
//        let newUser = PFUser()
//        newUser.username = usernameText.text
//        newUser.password = passwordText.text
//        let phonenumber: String = phoneText.text!
//        newUser["phone"] = storeAsPhone(phonenumber)
//        if(phonenumber.characters.count==10){
//            // call sign up function on the object
//            newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    print("User Registered successfully")
//                    self.performSegueWithIdentifier("signUpSegue", sender: nil)
//                    // manually segue to logged in view
//                }
//            }
//        }else{
//            print("invalid phone number")
//        }
//        newUser["follow"]=""
//        newUser["tracking"]=true
//    }
//    
    func storeAsPhone(phone: String)->String{
        let stringArray = phone.components(
            separatedBy: NSCharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        return newString
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
