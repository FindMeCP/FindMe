//
//  Contact.swift
//  FindMe
//
//  Created by William Tong on 3/22/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import AddressBook
import Parse

class Contact: NSObject {
    var contactPerson: ABRecordRef?
    var phonesArray: String?
    var friend: Bool?
    var onSite: Bool?
    
    init(contact: ABRecordRef, phone: String){
        contactPerson = contact
        phonesArray = phone
        friend = false
        onSite = false
    }
    
    func getName()->ABRecordRef{
        return contactPerson!
    }
    
    func getPhone()->String{
        return phonesArray!
    }
    
    func ifFriend()->Bool{
        return friend!
    }
    
    func ifOnSite()->Bool{
        let query = PFQuery(className: "UserMedia")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = 20
        /*
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (user: [PFObject]?, error: NSError?) -> Void in
        if let user = user {
        let tempMedia = UserMedia.mediaWithArray(media)
        UserMedia.processFilesWithArray(tempMedia, completion: { () -> Void in
        print("reloading table")
        self.tableView.reloadData()
        })
        self.userMedia = tempMedia
        } else {
        // handle error
        print("error fetching data")
        }
        }
        */
        return onSite!
    }
    
    class func processFilesWithArray(array: [Contact], completion: () -> ()) {
        let group = dispatch_group_create()
        for contact in array {
            if let file = contact.contactPerson {
                dispatch_group_enter(group)
                file.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        //contact.contactPerson = data: data!)
                    }
                    dispatch_group_leave(group)
                })
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            print("converted all images")
            completion()
        }
    }
    
    class func mediaWithArray(array: [PFObject]) -> [Contact] {
        var media = [Contact]()
        
        for object in array {
            media.append(Contact(contact: object["contact"] as ABRecordRef, phone: object["phone"] as! String)  )
        }
        
        return media
    }
}
