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
    
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var loginToggleButton: UIButton!
    @IBOutlet weak var registerToggleButton: UIButton!

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerName: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    
    let locationManager = CLLocationManager()
    let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loading login view")
        
        // control FB login button
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]

        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 16, y: view.frame.height-70, width: view.frame.width - 32, height: 50)

        // location settings
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        loginView.isHidden = false
        registerView.isHidden = true
        
        optionView.layer.cornerRadius = 10.0
        optionView.clipsToBounds = true
        optionView.layer.borderColor = UIColor.lightGray.cgColor
        optionView.layer.borderWidth = 1.0

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
        FriendsAPI.instance.loginFBAccount(credentials) { (completion, error) in
            print(completion)
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
    @IBAction func loginSubmit(_ sender: Any) {
        FriendsAPI.instance.loginEmailAccount(loginEmail.text!, password: loginPassword.text!) { (completion, error) in
            if(completion) {
                print("successfully logged in")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                let alertController = UIAlertController(title: "Error",
                                                        message: error!.localizedDescription,
                                                        preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    

    @IBAction func registerSubmit(_ sender: Any) {
        FriendsAPI.instance.createEmailAccount(registerEmail.text!, password: registerPassword.text!, name: registerName.text!) { (completion, error) in
            if(completion) {
                print("registered successfully")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                let alertController = UIAlertController(title: "Error",
                                                        message: error!.localizedDescription,
                                                        preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func toggleLogin(_ sender: Any) {
        loginView.isHidden = false
        registerView.isHidden = true
        loginToggleButton.backgroundColor = UIColor(red: 202/256, green: 104/256, blue: 156/256, alpha: 1)
        loginToggleButton.setTitleColor(UIColor.white, for: .normal)
        registerToggleButton.backgroundColor = UIColor.white
        registerToggleButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    @IBAction func toggleRegister(_ sender: Any) {
        registerView.isHidden = false
        loginView.isHidden = true
        registerToggleButton.backgroundColor = UIColor(red: 202/256, green: 104/256, blue: 156/256, alpha: 1)
        registerToggleButton.setTitleColor(UIColor.white, for: .normal)
        loginToggleButton.backgroundColor = UIColor.white
        loginToggleButton.setTitleColor(UIColor.lightGray, for: .normal)
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
        if(textField==loginEmail || textField==registerEmail){
            textField.placeholder = "Email"
        }else if (textField==registerName){
            textField.placeholder = "Name"
        }else {
            textField.placeholder = "Password"
        }
    }

}
