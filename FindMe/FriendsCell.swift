//
//  FriendsCell.swift
//  FindMe
//
//  Created by William Tong on 3/10/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import AddressBook
import Parse

class FriendsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var name: String?
    var contact:PFObject?
    var friend: Bool?
    var user: User?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        friend = false
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
        add()
        if(friend==true){
            friend=false
            addButton.setImage(UIImage(named: "Unchecked"), forState: .Normal)
        }else{
            friend=true
            addButton.setImage(UIImage(named: "Checked"), forState: .Normal)
        }
    }
    
    func add() {
        //user?.addContact(contact!)
    }
}
