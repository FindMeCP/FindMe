//
//  FriendsCell.swift
//  FindMe
//
//  Created by William Tong on 8/6/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import Contacts

class FriendsCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityColor: UIView!
    @IBOutlet weak var followButton: UIButton!
    
    var name: String?
    var user: User?
    
    var followFunc: (() -> (Void))!
 
    @IBAction func followFriend(_ sender: Any) {
        followFunc()
    }
    
    func setFollowFunction(_ function: @escaping () -> Void) {
        self.followFunc = function
    }

    func setActivity(timeInterval: TimeInterval) {
        print("set activity")
        activityColor.layer.cornerRadius = 5
        activityColor.clipsToBounds = true
        if(user?.tracking == false) {
            activityColor.backgroundColor = UIColor.red
            activityLabel.text = "Tracking is off"
            followButton.setImage(UIImage(named: ""), for: .normal)
        } else if(timeInterval <= 15) {
            activityColor.backgroundColor = UIColor.green
            activityLabel.text = "Active Now"
        } else {
            activityColor.backgroundColor = UIColor.orange
            
            var interval: String = ""
            if(timeInterval < 60) {
                interval = String(Int(timeInterval)) + " seconds ago"
            } else if(timeInterval < 3600) {
                var minutes = "minutes"
                if(Int(timeInterval/60)==1) { minutes = "minute" }
                interval = String(Int(timeInterval/60)) + " \(minutes) ago"
            } else if(timeInterval < 86400) {
                var hours = "hours"
                if(Int(timeInterval/3600)==1) { hours = "hour" }
                interval = String(Int(timeInterval/3600)) + " \(hours) ago"
            } else {
                var days = "days"
                if(Int(timeInterval/86400)==1) { days = "day" }
                interval = String(Int(timeInterval/86400)) + " \(days) ago"
            }
            activityLabel.text = "Last Active: \(interval)"
        }
        
    }
}




