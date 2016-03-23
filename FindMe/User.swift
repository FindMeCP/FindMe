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
    var contacts: [Contact]?
    var friends: [Contact]?
    var location: CLLocationCoordinate2D?
    
    init(object: PFObject) {
        mediaFile = object["media"] as? PFFile
        username = object["username"] as? String
        contacts = object["contacts"] as? [Contact]
        friends = object["friends"] as? [Contact]
        location = object["location"] as? CLLocationCoordinate2D
    }

    func addContact(contact: Contact){
        contacts?.append(contact)
    }
    
    func getPhoneNumber(){
        
    }
    
    func getLocation()->CLLocationCoordinate2D{
        return location!
    }

}

