//
//  LoginViewController.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // control FB login button
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]

        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 16, y: view.frame.height-70, width: view.frame.width - 32, height: 50)

        // location settings
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out of FB")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("successfully logged in with FB")
        showUserInfo()
    }
    
    func showUserInfo() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {
            return
        }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FriendsAPI.system.loginFBAccount(credentials) { (completion) in
            print(completion)
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
    @IBAction func login(_ sender: Any) {
//        PFUser.logInWithUsername(inBackground: usernameText.text!, password: passwordText.text!) { (user, error) in
//                if user != nil {
//                    print("you're logged in!")
//                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
//                }
//                if ( error == nil) {
//                    print("success")
//                }
//                else if (error != nil) {
//                    NSLog(error.debugDescription)
//                }
//        }
    }
    
    @IBAction func signup(_ sender: Any) {
//        performSegue(withIdentifier: "signUpSegue", sender: self)
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
