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
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var contactName: String?
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
        contactNameLabel.text = contactName
    }
    
    @IBAction func addPerson(sender: AnyObject) {
        if(friend==true){
            unadd()
            friend=false
            addButton.setImage(UIImage(named: "Unchecked"), forState: .Normal)
        }else{
            print("added")
            add()
            friend=true
            addButton.setImage(UIImage(named: "Checked"), forState: .Normal)
        }
        let table = superview?.superview as! UITableView
        table.reloadData()
    }
    
    func add() {
        print("add to friends")
        var friend = user!["friends"] as! [String]
        friend.append(contact!.objectId!)
        user!["friends"] = friend
        user!.saveInBackground()
        let table = superview?.superview as! UITableView
        table.reloadData()
    }
    
    func unadd() {
        //user?.addContact(contact!)
        var friend = user!["friends"] as! [String]
        if(friend.count>0){
            for x in 0...friend.count{
                if(friend[x] == contact!.objectId!){
                    friend.removeAtIndex(x)
                }
            }
        }
        user!["friends"] = friend
        user!.saveInBackground()
        
    }
    
    func requestFriend(){
        
    }
}
