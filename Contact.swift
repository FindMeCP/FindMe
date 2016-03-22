//
//  Contact.swift
//  FindMe
//
//  Created by William Tong on 3/22/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import AddressBook

class Contact: NSObject {
    var contactPerson: ABRecordRef?
    var phonesArray  = Dictionary<String,String>()
    
    func getName()->ABRecordRef{
        return contactPerson!
    }
    
    func getPhone()->Dictionary<String,String>{
        return phonesArray
    }
}
