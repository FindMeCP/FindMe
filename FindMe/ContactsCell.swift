//
//  ContactsCell.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

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
            addButton.setImage(UIImage(named: "Checked"), for: .normal)
        }else{
            addButton.setImage(UIImage(named: "Unchecked"), for: .normal)
        }
    }
    
    @IBAction func addPerson(_ sender: Any) {
        if(friend==true){
            friend=false
            addButton.setImage(UIImage(named: "Unchecked"), for: .normal)
        }else{
            friend=true
            addButton.setImage(UIImage(named: "Checked"), for: .normal)
        }
    }
    
    
    
}


