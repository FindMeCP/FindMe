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
import ContactsUI

@available(iOS 9.0, *)
class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, CNContactPickerDelegate {
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    var user = PFUser.currentUser()
    var addressBook = ABAddressBookRef?()
    var contactList: [ABRecordRef]!
    var friendsList: [ABRecordRef]!
    var contactListCopy: [ABRecordRef]!
    var phonesList =  Array<Array<String>>()
    var phonesListCopy =  Array<Array<String>>()
    var phonesArray: [String]!
    var friendBook: [PFObject]! = []
    var contactBook: [Contact]!
    
    var contactsBook: [CNContact]!
    var contactDict: [NSDictionary] = []
    var arrayOfDict: [NSDictionary] = []
    var dictionary: NSDictionary = ["phone": "3146022911", "friend": true, "tracking": true]
    
    
    
    func getContacts() {
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                self.findContacts()
            }
        }
    }
    
    func findContacts () -> [CNContact]{
        
        let keys = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),CNContactPhoneNumbersKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        var contacts = [CNContact]()
        CNContact.localizedStringForKey(CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .GivenName
        
        let contactStoreID = CNContactStore().defaultContainerIdentifier()
        //print("\(contactStoreID)")
        
        
        do {
            
            try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest) { (let contact, let stop) -> Void in
                if contact.phoneNumbers.count > 0 {
                    contacts.append(contact)
                }
                
            }
        } catch let e as NSError {
            //print(e.localizedDescription)
        }
        print(contacts)
        contactsBook = contacts
        return contacts
        
    }
    
    func compareWithDatabase(completionHandler: (success:Bool) -> Void){
        var flag = false
        for x in 0...contactsBook.count-1 {
            for y in 0...contactsBook[x].phoneNumbers.count-1{
                let query = PFUser.query()
                let number = contactsBook[x].phoneNumbers[y].value as! CNPhoneNumber
                let phoneNumber = storeAsPhone(number.stringValue)
                print("\(phoneNumber)")
                query!.whereKey("phone", equalTo: phoneNumber)
                //query!.orderByAscending("username")
                query!.findObjectsInBackgroundWithBlock {
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
                            completionHandler(success: true)
                        }
                    } else {
                        // Log details of the failure
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
            }
        }

    }
    
    func storeAsPhone(phone: String)->String{
        let stringArray = phone.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let newString = stringArray.joinWithSeparator("")
        return newString
    }
    
    func showContactPickerController() {
        let contactPickerViewController = CNContactPickerViewController()
        
        contactPickerViewController.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0 ")
        
        contactPickerViewController.delegate = self
        
        
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        /*let status = ABAddressBookGetAuthorizationStatus()
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
        refreshContacts()*/
        
        
        getContacts()
        //showContactPickerController()

        compareWithDatabase({ (success) -> Void in
            if success {
                print("success")
                for object in self.friendBook{
                    print(object["username"])
                    let dictionary = ["phone": object["phone"],"friend":false,"tracking":false]
                    self.contactDict.append(dictionary)
                    self.user!["contacts"]=self.contactDict
                    self.user!.saveInBackground()
                }
            } else {
                print("no contacts")
            }
        })
        
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
            if contactsBook != nil {
                return contactsBook!.count
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
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactsIdentifier", forIndexPath: indexPath) as! ContactsCell
            let currentContact = contactsBook![indexPath.row]
            cell.contact = currentContact
            return cell
        }
        if tableView == self.friendsTableView{
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
    
    /*
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
     }*/
    
    
}
