//
//  AppContactsCell.swift
//  FindMe
//
//  Created by William Tong on 3/10/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Contacts
import Parse

class AppContactsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var name: String?
    var user = PFUser.currentUser()
    var contact:PFObject?
    var friend: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if(contact!["phone"] as? String == user!["follow"] as? String){
            friend = true
        }else{
            friend = false
        }
        //let contactPerson: PFObject = contact!
        if(friend==true){
            addButton.setImage(UIImage(named: "Checked"), forState: .Normal)
        }else{
            addButton.setImage(UIImage(named: "Unchecked"), forState: .Normal)
        }
        name = contact!["username"] as? String
        nameLabel.text = name
    }
    
    @IBAction func addPerson(sender: AnyObject) {
        if(friend==true){
            unadd()
            friend=false
            addButton.setImage(UIImage(named: "Unchecked"), forState: .Normal)
        }else{
            add()
            friend=true
            addButton.setImage(UIImage(named: "Checked"), forState: .Normal)
        }
        let table = superview?.superview as! UITableView
        table.reloadData()
    }
    
    func add() {
        //user?.addContact(contact!)
        //        let query = PFUser.query()
        //        query!.whereKeyExists("phone")
        //        query!.orderByAscending("username")
        //        query!.findObjectsInBackgroundWithBlock {
        //            (objects: [PFObject]?, error: NSError?) -> Void in
        //            if error == nil {
        //                // The find succeeded.
        //                // Do something with the found objects
        //                if let objects = objects {
        //                    for object in objects {
        //                        //print(object)
        //                        self.queryBook.append(object)
        //                    }
        //                }
        //            } else {
        //                // Log details of the failure
        //                print("Error: \(error!) \(error!.userInfo)")
        //            }
        //        }
        let aContact = user!["contacts"] as! NSDictionary
        if let track = aContact["friend"] as? Bool {
            if(track==true){
                user!["follow"] = contact!["phone"]
                user!.saveInBackground()
            }else{
                requestFriend()
            }
        }
    }
    
    func unadd() {
        //user?.addContact(contact!)
        user!["follow"] = ""
        user!.saveInBackground()
    }
    
    func requestFriend(){
        
    }
}
