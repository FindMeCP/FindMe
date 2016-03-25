//
//  ContactsViewController.swift
//  FindMe
//
//  Created by William Tong on 3/10/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import AddressBook
import Parse

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var addressBook = ABAddressBookRef?()
    var contactList: NSArray!
    var contactArray: ABRecordRef?
    var allPeople: NSArray!
    //var phonesArray: [String]?
    var phonesList: [[String]]?
    var userBook: [Contact]?
    var contactBook: [Contact]?
    
    func createAddressBook(){
        let user = PFUser.currentUser()
        var error: Unmanaged<CFError>?
        addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        //contactList = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        contactList = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, nil, ABPersonSortOrdering(kABPersonSortByFirstName)).takeRetainedValue() as [ABRecordRef]

        print(contactList)
        for record:ABRecordRef in contactList {
            let contactPerson: ABRecordRef = record
            let contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String
            print ("contactName \(contactName)")
        let phonesRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValueRef
            var phonesArray: [String] = []
        for var i:Int = 0; i < ABMultiValueGetCount(phonesRef); i++ {
            let value: String = ABMultiValueCopyValueAtIndex(phonesRef, i).takeRetainedValue() as! NSString as String
            let number = storeAsPhone(value)
            //print("Phone: \(label) = \(value)")
            print(number)
            phonesArray.append(number)
            }
            phonesList?.append(phonesArray)
            contactBook?.append(Contact(contact: record, phone: phonesArray))
        }
        user?.addObject([contactList, phonesList], forKey: "contacts")
        //user!.saveInBackgroundWithBlock({ (success, error) -> Void in })
    }
    
    func storeAsPhone(phone: String)->String{
        let stringArray = phone.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let newString = stringArray.joinWithSeparator("")
        return newString
    }
    
    func refreshContacts(){
        let status = ABAddressBookGetAuthorizationStatus()
        // open it
        
        var error: Unmanaged<CFError>?
        let aBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue()
        if aBook == nil {
            print(error?.takeRetainedValue())
            return
        }
        
        if status == .Denied || status == .Restricted {
            // user previously denied, to tell them to fix that in settings
            
            ABAddressBookRequestAccessWithCompletion(addressBook) {
                granted, error in
                
                if !granted {
                    // warn the user that because they just denied permission, this functionality won't work
                    // also let them know that they have to fix this in settings
                    return
                }
                
                self.createAddressBook()
            }
        }else{
            createAddressBook()
        }
    }

    
    
    
    func compareWithDatabase(){
        
        var query = PFUser.query()
        query!.whereKey("contacts", equalTo:"phone")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
    
        let status = ABAddressBookGetAuthorizationStatus()
        if status == .Denied || status == .Restricted {
            // user previously denied, to tell them to fix that in settings

            ABAddressBookRequestAccessWithCompletion(addressBook) {
                granted, error in
                
                if !granted {
                    // warn the user that because they just denied permission, this functionality won't work
                    // also let them know that they have to fix this in settings
                    return
                }
            
                self.createAddressBook()
            }
        }else{
            refreshContacts()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contactList != nil {
            return contactList!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
       let cell = tableView.dequeueReusableCellWithIdentifier("ContactsIdentifier", forIndexPath: indexPath) as! ContactsCell
        let record:ABRecordRef = contactList![indexPath.row]
        cell.contact = record
        return cell
    }
    
    
}
