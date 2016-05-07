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
import MessageUI

@available(iOS 9.0, *)
class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
    var user = PFUser.currentUser()
    var phonesArray: [String]!
    var queryBook: [PFObject]! = []
    var friendBook: [PFObject]! = []    //Contacts with app
    var friendList: [PFObject]! = []    //Friends
    var friendsDelete: [Int]! = []
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
        //print(contacts)
        contactsBook = contacts
        return contacts
        
    }
    
    func createAppContacts(){
        print("create friends")
        for x in 0...contactsBook.count-1 {
            for y in 0...contactsBook[x].phoneNumbers.count-1{
                let number = contactsBook[x].phoneNumbers[y].value as! CNPhoneNumber
                let phoneNumber = storeAsPhone(number.stringValue)
                //print("\(phoneNumber)")
                for object in queryBook{
                    print(phoneNumber)
                    print(object["phone"] as! String)
                    if(phoneNumber == (object["phone"] as! String)){
                        print("appended")
                        friendBook.append(object)
                        self.tableView.reloadData()
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
    
    func loadFriends(){
        
    }
    
    func addFriend(){
        
    }
    
    var person: PFObject?
    
    func searchByUsername(username:String, completionHandler: (success:Bool) -> Void){
        let query = PFUser.query()
        query!.whereKeyExists("username")
        query!.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        if(object["username"] as! String == username){
                            self.person = object
                            completionHandler(success: true)
                        }
                    }
                    
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func storeAsPhone(phone: String)->String{
        let stringArray = phone.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let newString = stringArray.joinWithSeparator("")
        return newString
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
                        //print(object)
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
    
    func getFriendQuery(completionHandler: (success:Bool) -> Void){
        //var flag = false
        print("friendquery")
        print(user!["username"])
        print(user!["friends"])
        if let friendsArray = user!["friends"] as? [String]{
            print(friendsArray)
            let query = PFUser.query()
            query!.orderByDescending("username")
                print("friend occuring")
            for x in 0...friendsArray
                .count-1{
                query!.getObjectInBackgroundWithId(friendsArray[x]) {
                    (object: PFObject?, error: NSError?) -> Void in
                    if error == nil && object != nil {
                        self.friendList.append(object!)
                        //print(object)
                        completionHandler(success: true)
                    } else {
                        print(error)
                    }
                }
                if(x==friendsArray.count-1){
                    print("friends completed")
                }
            
            }
        }
        
    }
    
    func filterFriendBook(){
        if(friendList.count>0){
            print("comparing")
            for y in 0...friendList.count-1{
                for z in 0...friendBook.count-1{
                    print(friendList[y])
                    print(friendBook[z])
                    if(friendList[y]["username"] as! String == friendBook[z]["username"] as! String){
                        print("same!")
                        friendsDelete.append(z)
                    }
                }
            }
        }
        
        if friendsDelete.count != 0 {
            for w in 0...friendsDelete.count-1{
                let i = friendsDelete.count-1-w
                let j = friendsDelete[i]
                friendBook.removeAtIndex(j)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user!.saveInBackground()
        getContacts({(success) -> Void in
            print("getContacts")
//            self.getFriendQuery({ (success) -> Void in
//                print("getFriends")
//                if success{
                    self.getQuery({ (success) -> Void in
                        print("getQuery")
                        if success {
                            self.createAppContacts()
                            print("success")
                            self.getFriendQuery({ (success) in
                                if(success){
                                    print("getFriends")
                                    self.filterFriendBook()
                                    self.tableView.reloadData()
                                    self.friendsTableView.reloadData()
                                }else{
                                    print("failed")
                                }
                                //print("success")
                            })
                        } else {
                            print("no contacts")
                        }
                    })
//                }else{
//                    print("no friends")
//                }
//                
//            })
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            return 50
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView()
        if tableView == self.tableView {
            headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)

            let labelView = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 30))
            var userPath = ""
            
            if(section==0){
                userPath = "Contacts with App"
            }
            if(section==1){
                userPath = "Contacts without App"
            }
            labelView.text = userPath
            headerView.addSubview(labelView)
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            if section == 1 {
                return (contactsBook!.count)
            } else if(section == 0){
                return friendBook.count
            }else {
                return 0
            }
        }
        if tableView == self.friendsTableView {
            if friendList != nil {
                //print("friends")
                //print(friendBook!.count)
                return friendList!.count
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
            if indexPath.section==1{
                let cell = tableView.dequeueReusableCellWithIdentifier("ContactsIdentifier", forIndexPath: indexPath) as! ContactsCell
                //print(indexPath.row)
                if(indexPath.row < contactsBook!.count){
                    let currentContact = contactsBook![indexPath.row]
                    cell.contact = currentContact
                }
                return cell
            }
            if indexPath.section==0{
                let cell = tableView.dequeueReusableCellWithIdentifier("AppContactsIdentifier", forIndexPath: indexPath) as! AppContactsCell
                print(indexPath.row)
                if(indexPath.row < contactsBook!.count){
                    let record: PFObject = friendBook![indexPath.row]
                    cell.contact = record
                }
                return cell
            }
        }
        if tableView == self.friendsTableView{
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendsIdentifier", forIndexPath: indexPath) as! FriendsCell
            let record:PFObject = friendList![indexPath.row]
            cell.contact = record
            return cell
        }
        return blank
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let contact = contactsBook![indexPath.row]
        let phone = contact.phoneNumbers[0].value as! CNPhoneNumber
        let number = storeAsPhone(phone.stringValue)
        if tableView == self.tableView {

            let messageVC = MFMessageComposeViewController()
        
            messageVC.body = "Join me on FindMe!";
            messageVC.recipients = ["\(number)"]
            messageVC.messageComposeDelegate = self
            self.presentViewController(messageVC, animated: false, completion: nil)
        }

        
    }
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
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
    
    func refresh(){
        friendsTableView.reloadData()
    }
}
