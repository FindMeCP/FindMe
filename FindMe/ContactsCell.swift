//
//  ContactsCell.swift
//  FindMe
//
//  Created by William Tong on 3/10/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactSwitch: UISwitch!
    
    var name: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
     nameLabel.text = name
    }
}
