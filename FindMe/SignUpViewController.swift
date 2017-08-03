
//  SignUpViewController.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
//import Parse

class SignUpViewController: UIViewController, UIPopoverControllerDelegate {
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var phoneText: UITextField!
    
//    var newUser = PFUser()
    var usernameTaken = false
    var phoneTaken = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func createNewUser(completionHandler: @escaping (_ success:Bool) -> Void) {
//        newUser.username = usernameText.text
//        newUser.password = passwordText.text
//        let phoneNumber: String = phoneText.text!
//        let storedNumber = storeAsPhone(phone: phoneNumber)
//        newUser["phone"] = storedNumber
//        newUser["follow"] = ""
//        newUser["tracking"] = true
//        newUser["friends"] = []
//        let usernameQuery = PFUser.query()
//        usernameQuery?.whereKey("username", equalTo: newUser.username!)
//        usernameQuery?.findObjectsInBackground(block: { (objects, error) in
//            if error == nil {
//                if (objects!.count > 0){
//                    self.usernameTaken = true
//                    print("username is taken")
//                    
//                } else {
//                    print("Username is available. ")
//                    let phoneQuery = PFUser.query()
//                    phoneQuery?.whereKey("phone", equalTo: storedNumber)
//                    phoneQuery?.findObjectsInBackground(block: { (objects, error) in
//                        if error == nil {
//                            if (objects!.count > 0){
//                                self.phoneTaken = true
//                                print("Phone Number is taken")
//                            } else {
//                                print("Phone Number is available. ")
//                                completionHandler(true)
//                            }
//                        } else {
//                            print("error" + error.debugDescription)
//                        }
//                    })
//                }
//            } else {
//                print("error" + error.debugDescription)
//            }
//        })
//
//    }
//    
//    func storeAsPhone(phone: String)->String{
//        let stringArray = phone.components(
//            separatedBy: NSCharacterSet.decimalDigits.inverted)
//        let newString = stringArray.joined(separator: "")
//        return newString
//    }
//
//    @IBAction func signUp(_ sender: Any) {
//        let verificationPhone = "+1" + self.storeAsPhone(phone: phoneText.text!)
//        if usernameText.text == nil || passwordText.text == nil {
//            print("please enter a valid username and password")
//        }else {
//            createNewUser { (success) in
//                
//                self.newUser.signUpInBackground { (success, error) in
//                    PFUser.logInWithUsername(inBackground: self.newUser.username!, password: self.newUser.password!) { (user, error) in
//                        if user != nil {
//                            print("you're logged in!")
//                            self.performSegue(withIdentifier: "newUserSegue", sender: nil)
//                        }
//                    }
//                }
//                
//
//            }
//        }
//        
//        
//    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "newUserSegue") {
//        }
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        view.endEditing(true)
//        super.touchesBegan(touches, with: event)
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return false
//    }
//    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        textField.placeholder = nil
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField) {    //delegate method
//        if textField==usernameText {
//            textField.placeholder = "Username"
//        }else if textField==usernameText{
//            textField.placeholder = "Password"
//        }else {
//            textField.placeholder = "Phone Number"
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
