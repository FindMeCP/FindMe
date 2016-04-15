//
//  ContactsCell.swift
//  FindMe
//
//  Created by William Tong on 3/10/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse
import Contacts
import MessageUI

@available(iOS 9.0, *)
protocol CustomCellDeerCallsDelegate {
    func showMessage(title:String, message:String)
}

@available(iOS 9.0, *)
class ContactsCell: UITableViewCell, MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var name: String?
    var contact:CNContact?
    var friend: Bool?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contactPerson = contact!
        name = "\(contactPerson.givenName) \(contactPerson.familyName)"
        nameLabel.text = name
        friend = false
        if(friend==true){
            addButton.setImage(UIImage(named: "Checked"), forState: .Normal)
        }else{
            addButton.setImage(UIImage(named: "Unchecked"), forState: .Normal)
        }
    }
    
    @IBAction func addPerson(sender: AnyObject) {
        add()
        if(friend==true){
            friend=false
            addButton.setImage(UIImage(named: "Unchecked"), forState: .Normal)
        }else{
            friend=true
            addButton.setImage(UIImage(named: "Checked"), forState: .Normal)
        }
    }
    
    func add(){
        let viewController : UIViewController = ContactsViewController()
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Enter a message";
        messageVC.recipients = ["Enter tel-nr"]
        messageVC.messageComposeDelegate = self;
        viewController.presentViewController(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.window?.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            self.window?.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.window?.rootViewController!.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
}
