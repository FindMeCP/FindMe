//
//  EnterCodeViewController.swift
//  FindMe
//
//  Created by William Tong on 1/14/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import SinchVerification
import Parse

class EnterCodeViewController: UIViewController {

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var verification: Verification!
    var newUser: PFUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.isHidden = true
        indicator.isHidden = true
        print("NEW USER INFO")
        if newUser != nil {
            print(newUser.username!)
            print(newUser.password!)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func verify(_ sender: Any) {
        statusLabel.isHidden = false
        indicator.isHidden = false
        indicator.startAnimating()
        verifyButton.isEnabled = false
        statusLabel.text  = "Checking"
        codeTextField.isEnabled = false
        verification.verify(codeTextField.text!,
            completion: { (success, error) in
                self.indicator.stopAnimating()
                self.verifyButton.isEnabled = true
                self.codeTextField.isEnabled = true
                if (success) {
                    self.statusLabel.text = "Verified"
                    UIView.animate(withDuration: 1.0, animations: { 
                        self.statusLabel.text = "Creating User..."
                    })
                    self.createNewUser()
                } else {
                    self.statusLabel.text = error.debugDescription
                }
        })
    }
    
    func createNewUser() {
        newUser.signUpInBackground { (success, error) in
            PFUser.logInWithUsername(inBackground: self.newUser.username!, password: self.newUser.password!) { (user, error) in
                if user != nil {
                    print("you're logged in!")
                    self.performSegue(withIdentifier: "newUserSegue", sender: nil)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
