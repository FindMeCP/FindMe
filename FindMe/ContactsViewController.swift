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
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
    var user = PFUser.currentUser()
    var phonesArray: [String]!
    var queryBook: [PFObject]! = []
    var friendBook: [PFObject]! = []
    var contactsDelete: [Int]! = []
    var contactsBook: [CNContact]!
    var contactDict: [NSDictionary] = []
    
    func getContacts(completionHandler: (success:Bool) -> Void) {
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                self.findContacts()
                self.tableView.reloadData()
                completionHandler(success: true)
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
        
        do {
            try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest) { (let contact, let stop) -> Void in
                if contact.phoneNumbers.count > 0 {
                    contacts.append(contact)
                }
                
            }
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        print(contacts)
        contactsBook = contacts
        return contacts
        
    }
    
    func getQuery(completionHandler: (success:Bool) -> Void){
        //var flag = false
        let query = PFUser.query()
        query!.whereKeyExists("phone")
        query!.orderByAscending("username")
        query!.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        print(object)
                        self.queryBook.append(object)
                    }
                    completionHandler(success: true)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func createFriends(){
        print("create friends")
        for x in 0...contactsBook.count-1 {
            for y in 0...contactsBook[x].phoneNumbers.count-1{
                let number = contactsBook[x].phoneNumbers[y].value as! CNPhoneNumber
                let phoneNumber = storeAsPhone(number.stringValue)
                //print("\(phoneNumber)")
                for object in queryBook{
                    print(object["phone"] as! String)
                    if(phoneNumber == (object["phone"] as! String)){
                        print("appended")
                        friendBook.append(object)
                        self.friendsTableView.reloadData()
                        contactsDelete.append(x)
                    }
                }
            }
        }
        if contactsDelete.count != 0 {
            for x in 0...contactsDelete.count-1{
                let i = contactsDelete.count-1-x
                let z = contactsDelete[i]
                contactsBook.removeAtIndex(z)
            }
        }
        tableView.reloadData()
    }
    
    func storeAsPhone(phone: String)->String{
        let stringArray = phone.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let newString = stringArray.joinWithSeparator("")
        return newString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getContacts({(success) -> Void in

            self.getQuery({ (success) -> Void in
                if success {
                    self.createFriends()
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
            
        })
    
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.rowHeight = UITableViewAutomaticDimension
        friendsTableView.estimatedRowHeight = 150
        
        friendsTableView.hidden = false
        tableView.hidden = true
        
        friendsButton.backgroundColor = UIColor.lightGrayColor()
        contactsButton.backgroundColor = UIColor.whiteColor()
        friendsButton.layer.cornerRadius = 10.0
        friendsButton.clipsToBounds = true
        contactsButton.layer.cornerRadius = 10.0
        contactsButton.clipsToBounds = true

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
        friendsButton.backgroundColor = UIColor.lightGrayColor()
        contactsButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func contactsTable(sender: AnyObject) {
        friendsTableView.hidden = true
        tableView.hidden = false
        friendsButton.backgroundColor = UIColor.whiteColor()
        contactsButton.backgroundColor = UIColor.lightGrayColor()
    }    
    
}
