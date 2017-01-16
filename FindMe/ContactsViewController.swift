//
//  ContactsViewController.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
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
    var user = PFUser.current()
    
    var queryBook: [PFObject]! = []
    var friendQueryBook: [PFObject]! = []
    
    var usersBook: [PFObject]! = []    //Contacts with app
    var friendBook: [PFObject]! = []    //Friends
    var friendRequestBook: [PFObject]! = []    //Friend requests
    
    var contactsBook: [CNContact] = []
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.titleView = selectionView
        
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
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        friendsTableView.tableHeaderView = searchController.searchBar
        
        friendsTableView.isHidden = false
        tableView.isHidden = true
        
        selectionView.layer.cornerRadius = 10.0
        selectionView.clipsToBounds = true
        selectionView.layer.borderColor = UIColor.lightGray.cgColor
        selectionView.layer.borderWidth = 1.0
        
    }
    
    
    // retrieves contacts and loads them into contactsBook variable (used to load tableView)
    func getContacts(completionHandler: @escaping (_ success:Bool) -> Void) {
        AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                self.findContacts()
                self.tableView.reloadData()
                completionHandler(true)
            }
        }
    }
    
    func findContacts() {
        
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey] as [Any]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        var contacts = [CNContact]()
        CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
        if #available(iOS 10.0, *) {
            fetchRequest.mutableObjects = false
        } else {
            // Fallback on earlier versions
        }
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .givenName
        
        do {
            try CNContactStore().enumerateContacts(with: fetchRequest) { ( contact, stop) -> Void in
                if contact.phoneNumbers.count > 0 {
                    contacts.append(contact)
                }
                
            }
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        contactsBook = contacts
    }
    
    
    
    func storeAsPhone(phone: String)->String{
        let stringArray = phone.components(separatedBy:
            NSCharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        return newString
    }
    
    func getQuery(completionHandler: @escaping (_ success:Bool) -> Void){
        //var flag = false
        let query = PFUser.query()
        query!.whereKeyExists("phone")
        query!.order(byAscending: "username")
        query!.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        //print(object)
                        self.friendQueryBook.append(object)
                        self.queryBook.append(object)
                    }
                    completionHandler(true)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
            }
        })
    }
    
    var appContactNames: [String]! = []
    
    func createAppContacts(){
        print("create friends")
        var contactsDelete:[Int] = []
        for x in 0...contactsBook.count-1 {
            let number = contactsBook[x].phoneNumbers[0].value
            
            let phoneNumber = storeAsPhone(phone: number.stringValue)
            print("\(phoneNumber)")
            for object in queryBook{
                if(phoneNumber == (object["phone"] as! String)){
                    print("appended")
                    print(phoneNumber)
                    usersBook.append(object)
                    let name = "\(contactsBook[x].givenName) \(contactsBook[x].familyName)"
                    appContactNames.append(name)
                    self.tableView.reloadData()
                    contactsDelete.append(x)
                }
            }
        }
        print(contactsBook)
        print(contactsDelete)
        if contactsDelete.count != 0 {
            for x in 0...contactsDelete.count-1{
                let i = contactsDelete.count-1-x
                let z = contactsDelete[i]
                contactsBook.remove(at: z)
            }
        }
        tableView.reloadData()
    }
    
    var friendList: [String]?
    
    func getFriendQuery(completionHandler: @escaping (_ success:Bool) -> Void){
        print("hello")
        let query = PFUser.query()
        query!.whereKeyExists("_id")
        query!.order(byDescending: "username")
        query!.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                print("friends query")
                if let objects = objects {
                    for object in objects {
                        print(object)
                        self.friendQueryBook.append(object)
                    }
                    completionHandler(true)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
            }
        })
    }
    
    func createFriends(){
        let friendRequest = 1
        let currentFriend = 2
        if let friendsArray = user!["friends"] as? [NSDictionary]{
            print("JSON DATA")
            if friendsArray.count > 0 {
                for friend in friendsArray {
                    for y in 0...friendQueryBook.count-1{
                        let friendId = friend["id"] as? String
                        if let friendType = friend["type"] as? Int {
                            if (friendType==friendRequest) {
                                if(friendQueryBook[y].objectId == friendId){
                                    friendRequestBook.append(friendQueryBook[y] )
                                    self.friendsTableView.reloadData()
                                    
                                }
                            }
                            if (friendType==currentFriend) {
                                if(friendQueryBook[y].objectId == friendId){
                                    friendBook.append(friendQueryBook[y] )
                                    self.friendsTableView.reloadData()
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        filteredFriendBook = friendBook
    }
    
    func filterUsersBook(){
        var friendsDelete: [Int] = []
        if(friendBook.count>0 && usersBook.count>0){
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
                usersBook.remove(at: j)
                appContactNames.remove(at: j)
            }
        }
        print("filtered")
    }
    
    

    
    func loadContacts(){
        getContacts(completionHandler: {(success) -> Void in
            print("getContacts")
            self.getQuery(completionHandler: { (success) -> Void in
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
    
    func numberOfSections(in tableView: UITableView) -> Int {

        if tableView == self.tableView {
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView {
            return 30
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView()
        if tableView == self.tableView {
            headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 5))
            headerView.backgroundColor = UIColor.lightGray
            
            let labelView = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 20))
            labelView.font = UIFont.systemFont(ofSize: 12)
            
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            if section == 1 {
                return contactsBook.count
                
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let blank = UITableViewCell()
        if tableView == self.tableView {
            if indexPath.section==1{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsIdentifier", for: indexPath as IndexPath) as! ContactsCell
                //print(indexPath.row)
                //cell.selectionStyle = UITableViewCellSelectionStyle.none
                //cell.contentView.isUserInteractionEnabled = false
                if(indexPath.row < contactsBook.count){
                    let currentContact = contactsBook[indexPath.row]
                    cell.contact = currentContact
                    cell.viewController = self
                }
                return cell
            }
            if indexPath.section==0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "AppContactsIdentifier", for: indexPath as IndexPath) as! AppContactsCell
                if(indexPath.row < contactsBook.count){
                    let record: PFObject = usersBook![indexPath.row]
                    cell.contactName = appContactNames[indexPath.row]
                    cell.contact = record
                }
                return cell
            }
        }
        if tableView == self.friendsTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsIdentifier", for: indexPath as IndexPath) as! FriendsCell
            let record:PFObject = filteredFriendBook![indexPath.row]
            cell.contact = record
            return cell
        }
        return blank
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
//        print("HI")
//    }
    
    func presentMessage(contact:CNContact){
        let phone = contact.phoneNumbers[0].value
        let number = storeAsPhone(phone: phone.stringValue)
        if tableView == self.tableView {
            
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "Join me on FindMe!\nMy username is: " +  self.user!.username!;
            messageVC.recipients = ["\(number)"]
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: false, completion: nil)
        }
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
    
    // functions for when friend or contact tab is pressed
    
    @IBAction func friendsTable(_ sender: Any) {
        friendsTableView.isHidden = false
        tableView.isHidden = true
        friendsButton.backgroundColor = UIColor(red: 202/256, green: 104/256, blue: 156/256, alpha: 1)
        friendsButton.setTitleColor(UIColor.white, for: .normal)
        contactsButton.backgroundColor = UIColor.white
        contactsButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    @IBAction func contactsTable(_ sender: Any) {
        friendsTableView.isHidden = true
        tableView.isHidden = false
        friendsButton.setTitleColor(UIColor.lightGray, for: .normal)
        friendsButton.backgroundColor = UIColor.white
        contactsButton.backgroundColor = UIColor(red: 202/256, green: 104/256, blue: 156/256, alpha: 1)
        contactsButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    
    func addFriends(_ sender: Any) {
        performSegue(withIdentifier: "addFriendsSegue", sender: self)
    }
    
        
    func acceptRequest(username:String, completionHandler: @escaping (_ success:Bool) -> Void){
        let query = PFUser.query()
        query!.whereKeyExists("username")
        query!.findObjectsInBackground(block: { (objects, error) in
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
                            
                            completionHandler(true)
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.localizedDescription)")
            }
        })
    }
    
    var filteredFriendBook: [PFObject]!
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredFriendBook = searchText.isEmpty ? friendBook : friendBook.filter({(dataString: PFObject) -> Bool in
                return (dataString["username"] as! String).range(of: searchText, options: .caseInsensitive) != nil
            })
            
            friendsTableView.reloadData()
        }
    }
    
    func refresh(){
        friendsTableView.reloadData()
    }
}

