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
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    var addressBook = ABAddressBookRef?()
    var contactList: [ABRecordRef]!
    var friendsList: [ABRecordRef]!
    var contactListCopy: [ABRecordRef]!
    var phonesList =  Array<Array<String>>()
    var phonesListCopy =  Array<Array<String>>()
    var phonesArray: [String]!
    var friendBook: [PFObject]! = []
    var contactBook: [Contact]!
    
    func createAddressBook(){
        let user = PFUser.currentUser()
        var error: Unmanaged<CFError>?
        addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        contactList = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, nil, ABPersonSortOrdering(kABPersonSortByFirstName)).takeRetainedValue() as [ABRecordRef]
        //print(contactList)
        for record:ABRecordRef in contactList {
            let contactPerson: ABRecordRef = record
            let contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String
            //print ("contactName \(contactName)")
        let phonesRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValueRef
            var phonesArray: [String] = []
        for var i:Int = 0; i < ABMultiValueGetCount(phonesRef); i++ {
            let value: String = ABMultiValueCopyValueAtIndex(phonesRef, i).takeRetainedValue() as! NSString as String
            let number = storeAsPhone(value)
           // print("Phone: \(label) = \(value)")
            //print(number)
            phonesArray.append(number)
            }
            //print(phonesArray)
            phonesList.append(phonesArray)
        }
        contactListCopy = contactList
        phonesListCopy = phonesList
        for object in phonesList{
            //print(object)
        }
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
            //print(error?.takeRetainedValue())
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
        var inList = false
        for(var x=0; x < phonesList.count; x++){
            for(var y=0; y<phonesList[x].count; y++){
                //print(contactList[x])
                //print(phonesList[x][y])
                let innerQuery = PFUser.query()
                innerQuery!.whereKey("phone", equalTo: phonesList[x][y])
                innerQuery!.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        // The find succeeded.
                        // Do something with the found objects
                        if let objects = objects {
                            for object in objects {
                                print(object)
                                self.friendBook.append(object)
                                print(self.friendBook[0])
                                self.friendsTableView.reloadData()
                            }
                        }
                    } else {
                        // Log details of the failure
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
/*
                innerQuery!.getFirstObjectInBackgroundWithBlock() {
                    (object: PFObject?, error: NSError?) -> Void in
                    if error == nil {
                        inList = true
                        print("hi")
                        print(object)
                    }
                }*/
                if(inList){
                    print("hello")
                    friendsList.append(self.contactList[x])
                    contactListCopy.removeAtIndex(x)
                    phonesList.removeAtIndex(x)
                }
                //inList = false
            }
        }
        print("yo")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
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
        //}else{
        //    refreshContacts()
        }
        refreshContacts()
        
        compareWithDatabase()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.rowHeight = UITableViewAutomaticDimension
        friendsTableView.estimatedRowHeight = 150
        
        friendsTableView.hidden = true
        tableView.hidden = true
        

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            if contactListCopy != nil {
                print("contact")
                return contactListCopy!.count
            } else {
                return 0
            }
        }
        if tableView == self.friendsTableView {
            if friendBook != nil {
                //print("friends")
                print(friendBook!.count)
                return friendBook!.count
            } else {
                return 0
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let blank = UITableViewCell()
        if tableView == self.tableView {
            print("contacts")
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactsIdentifier", forIndexPath: indexPath) as! ContactsCell
            let record:ABRecordRef = contactListCopy![indexPath.row]
            cell.contact = record
            return cell
        }
        if tableView == self.friendsTableView{
            print("friends")
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendsIdentifier", forIndexPath: indexPath) as! FriendsCell
            let record:PFObject = friendBook![indexPath.row]
            cell.contact = record
            return cell
        }
        return blank
    }
    
    @IBAction func friendsTable(sender: AnyObject) {
        friendsTableView.hidden = false
        tableView.hidden = true
    }
    
    @IBAction func contactsTable(sender: AnyObject) {
        friendsTableView.hidden = true
        tableView.hidden = false
    }
    
    
    
}
