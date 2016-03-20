//
//  MainViewController.swift
//  FindMe
//
//  Created by William Tong on 3/8/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if self.revealViewController() != nil {
            settingsButton.target = self.revealViewController()
            settingsButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()

    }
    
   
    
}
