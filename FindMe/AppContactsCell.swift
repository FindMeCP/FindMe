//
//  AppContactsCell.swift
//  FindMe
//
//  Created by William Tong on 1/3/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import Contacts
import Parse

@available(iOS 9.0, *)

class AppContactsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var contactName: String?
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
            addButton.setImage(UIImage(named: "PinkCheck"), for: .normal)
        }else{
            addButton.setImage(UIImage(named: "PinkAdd"), for: .normal)
        }
        name = contact!["username"] as? String
        nameLabel.text = name
        contactNameLabel.text = contactName
    }
    
    @IBAction func addPerson(_ sender: Any) {
        if(friend==true){
            unadd()
            friend=false
            addButton.setImage(UIImage(named: "PinkAdd"), for: .normal)
        }else{
            print("added")
            add()
            friend=true
            addButton.setImage(UIImage(named: "PinkCheck"), for: .normal)
        }
        let table = superview?.superview as! UITableView
        table.reloadData()
    }
    
    
    // FIXME!!!
    func add() {
        print("add to friends")
        var friend = user!["friends"] as! [String]
        friend.append(contact!.objectId!)
        user!["friends"] = friend
        user!.saveInBackground()
        let table = superview?.superview as! UITableView
        table.reloadData()
    }
    
    // FIXME!!
    func unadd() {
        //user?.addContact(contact!)
        var friend = user!["friends"] as! [String]
        if(friend.count>0){
            for x in 0...friend.count{
                if(friend[x] == contact!.objectId!){
                    friend.remove(at: x)
                }
            }
        }
        user!["friends"] = friend
        user!.saveInBackground()
        
    }
    
}
