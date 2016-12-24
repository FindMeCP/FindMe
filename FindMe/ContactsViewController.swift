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
class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, MFMessageComposeViewControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
    @IBOutlet weak var selectionView: UIView!
    var user = PFUser.currentUser()

    var queryBook: [PFObject]! = []
    var friendQueryBook: [PFObject]! = []
    
    var usersBook: [PFObject]! = []    //Contacts with app
    var friendBook: [PFObject]! = []    //Friends
    
    var contactsBook: [CNContact]!
    
    var searchController: UISearchController!
    
    // retrieves contacts and loads them into contactsBook variable (used to load tableView)
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
        contactsBook = contacts
        return contacts
        
    }
    

    
    func storeAsPhone(phone: String)->String{
        let stringArray = phone.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let newString = stringArray.joinWithSeparator("")
        return newString
    }
    
    /**
     Lorem ipsum dolor sit amet.
     
     @param bar Consectetur adipisicing elit.
     
     @return Sed do eiusmod tempor.
     */
    
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
                        self.friendQueryBook.append(object)
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
    
    var appContactNames: [String]! = []
    
    func createAppContacts(){
        print("create friends")
        var contactsDelete:[Int] = []
        for x in 0...contactsBook.count-1 {
            for y in 0...contactsBook[x].phoneNumbers.count-1{
                let number = contactsBook[x].phoneNumbers[y].value as! CNPhoneNumber
                let phoneNumber = storeAsPhone(number.stringValue)
                print("\(phoneNumber)")
                for object in queryBook{
                    if(phoneNumber == (object["phone"] as! String)){
                        print("appended")
                        usersBook.append(object)
                        let name = "\(contactsBook[x].givenName) \(contactsBook[x].familyName)"
                        appContactNames.append(name)
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

    var friendList: [String]?
    
    func getFriendQuery(completionHandler: (success:Bool) -> Void){
            print("hello")
            let query = PFUser.query()
            query!.whereKeyExists("_id")
            query!.orderByDescending("username")
            query!.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    // The find succeeded.
                    // Do something with the found objects
                    print("friends query")
                    if let objects = objects {
                        for object in objects {
                            print(object)
                            self.friendQueryBook.append(object)
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
        print(friendQueryBook)
        if let friendsArray = user!["friends"] as? [String]{
            for x in 0...friendsArray.count-1{
                print(friendsArray[x])
                    for y in 0...friendQueryBook.count-1{
                        if(friendQueryBook[y].objectId == (friendsArray[x])){
                            print("appended")
                            friendBook.append(friendQueryBook[y] )
                            self.friendsTableView.reloadData()

                        }
                    }
            }
        }
        filteredFriendBook = friendBook
    }
    
    func filterUsersBook(){
        var friendsDelete: [Int] = []
        if(friendBook.count>0){
            print("comparing")
            for z in 0...usersBook.count-1 {
                for y in 0...friendBook.count-1 {
                    if(friendBook[y]["username"] as! String == usersBook[z]["username"] as! String){
                        friendsDelete.append(z)
                    }
                }
            }
        }

        if friendsDelete.count != 0 && usersBook.count != 0{
            for w in 0...friendsDelete.count-1{
                let i = friendsDelete.count-1-w
                let j = friendsDelete[i]
                usersBook.removeAtIndex(j)
                appContactNames.removeAtIndex(j)
            }
        }
        print("filtered")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
        
    
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.rowHeight = UITableViewAutomaticDimension
        friendsTableView.estimatedRowHeight = 150
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.sizeToFit()
        friendsTableView.tableHeaderView = searchController.searchBar
        
        friendsTableView.hidden = false
        tableView.hidden = true
        
        selectionView.layer.cornerRadius = 10.0
        selectionView.clipsToBounds = true
        selectionView.layer.borderColor = UIColor.lightGrayColor().CGColor
        selectionView.layer.borderWidth = 1.0

    }
    
    func loadContacts(){
        getContacts({(success) -> Void in
            print("getContacts")
            self.getQuery({ (success) -> Void in
                print("getQuery")
                if success {
                    self.createAppContacts()
                    print("success")
//                    self.getFriendQuery({ (success) in
                        if(success){
                            print("getFriends")
                            self.createFriends()
                            self.filterUsersBook()
                            self.tableView.reloadData()
                            self.friendsTableView.reloadData()
                        }else{
                            print("failed")
                        }
                        //print("success")
//                    })
                } else {
                    print("no contacts")
                }
            })
            
        })
    }
    
    
    /*
    *   tableView methods to control for both tableViews
    */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            return 30
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView()
        if tableView == self.tableView {
            headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 5))
            headerView.backgroundColor = UIColor.lightGrayColor()

            let labelView = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 20))
            labelView.font = UIFont.systemFontOfSize(12)
            
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
                return usersBook.count
            }else {
                return 0
            }
        }
        if tableView == self.friendsTableView {
            if filteredFriendBook != nil {
                //print("friends")
                //print(usersBook!.count)
                return filteredFriendBook!.count
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
                if(indexPath.row < contactsBook!.count){
                    let record: PFObject = usersBook![indexPath.row]
                    cell.contactName = appContactNames[indexPath.row]
                    cell.contact = record
                }
                return cell
            }
        }
        if tableView == self.friendsTableView{
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendsIdentifier", forIndexPath: indexPath) as! FriendsCell
            let record:PFObject = filteredFriendBook![indexPath.row]
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

    // functions for when friend or contact tab is pressed
    
    @IBAction func friendsTable(sender: AnyObject) {
        friendsTableView.hidden = false
        tableView.hidden = true
        friendsButton.backgroundColor = UIColor(red: 202/256, green: 104/256, blue: 156/256, alpha: 1)
        friendsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        contactsButton.backgroundColor = UIColor.whiteColor()
        contactsButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
    }
    
    @IBAction func contactsTable(sender: AnyObject) {
        friendsTableView.hidden = true
        tableView.hidden = false
        friendsButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        friendsButton.backgroundColor = UIColor.whiteColor()
        contactsButton.backgroundColor = UIColor(red: 202/256, green: 104/256, blue: 156/256, alpha: 1)
        contactsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    
    @IBAction func addFriends(sender: AnyObject) {
        addByUsername("Random") { (success) in
            print("requesting friend")
        }
    }
    
    var person: PFObject?
    
    func addByUsername(username:String, completionHandler: (success:Bool) -> Void){
        let query = PFUser.query()
        query!.whereKeyExists("username")
        query!.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        if(object["username"] as? String == username){
                            if var friendsRequested = self.user?["friends_requested"] as? [String]{
                                var alreadyRequested = false
                                for person in friendsRequested{
                                    if object.objectId == person{
                                        alreadyRequested = true
                                    }
                                }
                                if !alreadyRequested {
                                    friendsRequested.append(object.objectId!)
                                    self.user?["friends_requested"] = friendsRequested
                                    self.user?.saveInBackground()
                                }
                            }
                            if var friendRequests = object["friend_requests"] as? [String] {
                                var alreadyRequested = false
                                for person in friendRequests{
                                    if object.objectId == person{
                                        alreadyRequested = true
                                    }
                                }
                                if !alreadyRequested {
                                    friendRequests.append(self.user!.objectId!)
                                    object["friend_requests"] = friendRequests
                                    object.saveInBackground()
                                }
                            }
                            
                            completionHandler(success: true)
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func acceptRequest(username:String, completionHandler: (success:Bool) -> Void){
        let query = PFUser.query()
        query!.whereKeyExists("username")
        query!.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        if(object["username"] as? String == username){
                            if var friendsRequested = self.user?["friends_requested"] as? [String]{
                                friendsRequested.append(object.objectId!)
                                self.user?["friends_requested"] = friendsRequested
                                self.user?.saveInBackground()
                            }
                            if var friendRequests = object["friend_requests"] as? [String] {
                                friendRequests.append(self.user!.objectId!)
                                object["friend_requests"] = friendRequests
                                object.saveInBackground()
                            }
                            
                            completionHandler(success: true)
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    var filteredFriendBook: [PFObject]!
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredFriendBook = searchText.isEmpty ? friendBook : friendBook.filter({(dataString: PFObject) -> Bool in
                return (dataString["username"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
            
            friendsTableView.reloadData()
        }
    }
    
    func refresh(){
        friendsTableView.reloadData()
    }
}
