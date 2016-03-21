//
//  ContactsViewController.swift
//  FindMe
//
//  Created by William Tong on 3/10/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import AddressBook

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var addressBook = ABAddressBookRef?()
    var contactList: NSArray!
    
    func createAddressBook(){
        var error: Unmanaged<CFError>?
        addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        contactList = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue()
        print(contactList)
        for record:ABRecordRef in contactList {
            let contactPerson: ABRecordRef = record
            let contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String
            print ("contactName \(contactName)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
    
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            print("Already authorized")
            createAddressBook()
            /* Access the address book */
        case .Denied:
            print("Denied access to address book")
            
        case .NotDetermined:
            createAddressBook()
            if let theBook: ABAddressBookRef = addressBook{
                ABAddressBookRequestAccessWithCompletion(theBook,
                    {(granted: Bool, error: CFError!) in
                        
                        if granted{
                            print("Access granted")
                        } else {
                            print("Access not granted")
                        }
                        
                })
            }
            
        case .Restricted:
            print("Access restricted")
        
            //not needed??? gives error
        //default:
        //    print("Other Problem")
        }
        //print(addressBook)
        
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
        //let contactPerson: ABRecordRef = record
        //let contactName: String = ABRecordCopyCompositeName(contactPerson).takeRetainedValue() as String
        //print ("contactName \(contactName)")
        //print(cell.name)
        cell.contact = record
        return cell
    }
    
    
}
