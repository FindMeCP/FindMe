//
//  LoginViewController.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Parse

class LoginViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PFCloud.callFunction(inBackground: "hello", withParameters: [:]) { (success, error) in
            print("dummy")
            if ( error == nil) {
                print("success")
                print(success.debugDescription)
            }
            else if (error != nil) {
                NSLog(error.debugDescription)
            }
        }
        
            
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
//        let loginButton = FBSDKLoginButton()
//        loginButton.center = view.center
//        view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        PFUser.logInWithUsername(inBackground: usernameText.text!, password: passwordText.text!) { (user, error) in
                if user != nil {
                    print("you're logged in!")
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
                if ( error == nil) {
                    print("success")
                }
                else if (error != nil) {
                    NSLog(error.debugDescription)
                }
        }
    }
    
    @IBAction func signup(_ sender: Any) {
        performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {    //delegate method
        if(textField==usernameText){
            textField.placeholder = "Username"
        }else{
            textField.placeholder = "Password"
        }
    }

}
