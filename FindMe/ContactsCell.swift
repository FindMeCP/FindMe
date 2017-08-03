//
//  ContactsCell.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Contacts


class ContactsCell: UITableViewCell{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var viewController : UIViewController?
    var name: String?
    var contact:CNContact?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contactPerson = contact!
        name = "\(contactPerson.givenName) \(contactPerson.familyName)"
        nameLabel.text = name
    }
    
    @IBAction func addPerson(_ sender: Any) {
//        if contact != nil {
//            if let contactsVC = self.viewController as? ContactsViewController {
//                contactsVC.presentMessage(contact: contact!)
//            }
//        }
    }
    
    
    
}


