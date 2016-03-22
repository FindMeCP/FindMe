//
//  User.swift
//  FindMe
//
//  Created by William Tong on 3/8/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse
import AddressBook
import CoreLocation

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var mediaFile: PFFile?
    var id: Int?
    var username: String?
    var contacts: [ABRecordRef]?
    var friends: [ABRecordRef]?
    var location: Int?
    
    init(object: PFObject) {
        mediaFile = object["media"] as? PFFile
        username = object["username"] as? String
        contacts = object["contacts"] as? [ABRecordRef]
        friends = object["friends"] as? [ABRecordRef]
    }

    func addContact(contact: ABRecordRef){
        contacts?.append(contact)
    }
    
    func getPhoneNumber(contact: ABRecordRef){
        
    }

}

