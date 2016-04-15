//
//  SideViewController.swift
//  FindMe
//
//  Created by William Tong on 4/7/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse


class SideViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var trackingButton: UISwitch!
    var user = PFUser.currentUser()
    var track: Bool?
    override func viewDidLoad() {
        if(user!["tracking"] as! Bool == true){
            trackingButton.on = true
            track = true
        }else{
            trackingButton.on = false
            track = false
        }
        usernameLabel.text = PFUser.currentUser()?.username
    }
    
    @IBAction func changeTracking(sender: AnyObject) {
        if(track!){
            track = false
            user!["tracking"] = false
            user!["follow"] = ""
            user!.saveInBackground()
            print("false")
        }else{
            track = true
            user!["tracking"] = true
            user!.saveInBackground()
            print("true")
        }
    }
    

}
