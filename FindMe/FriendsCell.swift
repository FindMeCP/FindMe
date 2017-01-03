//
//  FriendsCell.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

import UIKit
import Contacts
import Parse

class FriendsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var name: String?
    var user = PFUser.current()
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
            addButton.setImage(UIImage(named: "Checked"), for: .normal)
        }else{
            addButton.setImage(UIImage(named: "Unchecked"), for: .normal)
        }
        name = contact!["username"] as? String
        nameLabel.text = name
    }
    
    @IBAction func addPerson(_ sender: Any) {
        if(friend==true){
            unadd()
            friend=false
            addButton.setImage(UIImage(named: "Unchecked"), for: .normal)
        }else{
            add()
            friend=true
            self.addButton.setImage(UIImage(named: "Checked"), for: .normal)
        }
        let table = superview?.superview as! UITableView
        table.reloadData()
    }
    
    func add() {
        user!["follow"] = contact!["phone"]
        user!.saveInBackground()
    }
    
    func unadd() {
        //user?.addContact(contact!)
        user!["follow"] = ""
        user!.saveInBackground()
    }
    
    func requestFollow(){
        
    }
}




