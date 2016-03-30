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
import Contacts

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
        //let user = PFUser.currentUser()
        var error: Unmanaged<CFError>?
        addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        contactList = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, nil, ABPersonSortOrdering(kABPersonSortByFirstName)).takeRetainedValue() as [ABRecordRef]
        //print(contactList)
        for record:ABRecordRef in contactList {
            let contactPerson: ABRecordRef = record
            //let contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String
            //print ("contactName \(contactName)")
        let phonesRef: ABMultiValueRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty).takeRetainedValue() as ABMultiValueRef
            var phonesArray: [String] = []
        for i in 0...ABMultiValueGetCount(phonesRef){
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
        //for object in phonesList{
            //print(object)
        //}
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
    
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        if #available(iOS 9.0, *) {
            let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
            AppDelegate.getAppDelegate().contactStore
            switch authorizationStatus {
            case .Authorized:
                completionHandler(accessGranted: true)
                
            case .Denied, .NotDetermined:
                if #available(iOS 9.0, *) {
                    self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                        if access {
                            completionHandler(accessGranted: access)
                        }
                        else {
                            if authorizationStatus == CNAuthorizationStatus.Denied {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                                    self.showMessage(message)
                                })
                            }
                        }
                    })
                } else {
                    // Fallback on earlier versions
                }
                
            default:
                completionHandler(accessGranted: false)
            }
        } else {
            print("this function requires iOS 9+")
        }
        
        
    }

    
    
    
    func compareWithDatabase(){
        var inList = false
        for x in 0 ... phonesList.count {
            for y in 0 ... phonesList[x].count{
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
