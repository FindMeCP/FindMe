//
//  ContactsCell.swift
//  FindMe
//
//  Created by William Tong on 3/10/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse
import Contacts


@available(iOS 9.0, *)
class ContactsCell: UITableViewCell{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var name: String?
    var contact:CNContact?
    var friend: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contactPerson = contact!
        name = "\(contactPerson.givenName) \(contactPerson.familyName)"
        nameLabel.text = name
        friend = false
        if(friend==true){
            addButton.setImage(UIImage(named: "Checked"), forState: .Normal)
        }else{
            addButton.setImage(UIImage(named: "Unchecked"), forState: .Normal)
        }
    }
    
    @IBAction func addPerson(sender: AnyObject) {
        if(friend==true){
            friend=false
            addButton.setImage(UIImage(named: "Unchecked"), forState: .Normal)
        }else{
            friend=true
            addButton.setImage(UIImage(named: "Checked"), forState: .Normal)
        }
    }
    

    
}
