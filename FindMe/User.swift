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
    var location: Int?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        id = dictionary["id"] as? Int
        username = dictionary["name"] as? String
        contacts = dictionary["contacts"] as? [ABRecordRef]
        location = dictionary["location"] as? Int

    }
    /*
    init(object: PFObject) {
        mediaFile = object["media"] as? PFFile
        caption = object["caption"] as? String
        likesCount = object["likesCount"] as? Int
        commentsCount = object["commentsCount"] as? Int
    }*/

    func addContact(contact: ABRecordRef){
        contacts?.append(contact)
    }
    
    class var currentUser: User? {
        get {
        if _currentUser == nil {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
        if data != nil {
        do {
        let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
        _currentUser = User(dictionary: dictionary as! NSDictionary)
    } catch let error as NSError {
        print(error.localizedDescription)
        }
        }
        }
        return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: [])
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }


}

