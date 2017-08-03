//
//  AppContactsCell.swift
//  FindMe
//
//  Created by William Tong on 1/3/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import Contacts

@available(iOS 9.0, *)

class AppContactsCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var contactName: String?
    var name: String?
//    var user = PFUser.current()
//    var contact:PFObject?
    var friend: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if(contact!["phone"] as? String == user!["follow"] as? String){
//            friend = true
//        }else{
//            friend = false
//        }
//        //let contactPerson: PFObject = contact!
//        if(friend==true){
//            addButton.setImage(UIImage(named: "PinkCheck"), for: .normal)
//        }else{
//            addButton.setImage(UIImage(named: "PinkAdd"), for: .normal)
//        }
//        name = contact!["username"] as? String
//        nameLabel.text = name
//        contactNameLabel.text = contactName
    }
    
    @IBAction func addPerson(_ sender: Any) {
//        if(friend==true){
//            unadd()
//            friend=false
//            addButton.setImage(UIImage(named: "PinkAdd"), for: .normal)
//        }else{
//            print("added")
//            add()
//            friend=true
//            addButton.setImage(UIImage(named: "PinkCheck"), for: .normal)
//        }
//        let table = superview?.superview as! UITableView
//        table.reloadData()
    }
    
    
    // FIXME!!!
//    func add() {
//        print("add to friends")
//        makeFriends(user1: user!, user2: contact! as! PFUser)
////        if var friend = user!["friends"] as? [NSDictionary] {
////            let friendData: NSDictionary = ["id" : "\(contact!.objectId!)", "type" : 0 ]
////            friend.append(friendData)
////            user!["friends"] = friend
////            user!.saveInBackground()
////        } else {
////            var friend: [NSDictionary] = []
////            let friendData: NSDictionary = ["id" : "\(contact!.objectId!)", "type" : 0 ]
////            friend.append(friendData)
////            user!["friends"] = friend
////            user!.saveInBackground()
////        }
//        
//        let table = superview?.superview as! UITableView
//        table.reloadData()
//    }
    
    // FIXME!!
//    func unadd() {
//        //user?.addContact(contact!)
//        var friend = user!["friends"] as! [String]
//        if(friend.count>0){
//            for x in 0...friend.count{
//                if(friend[x] == contact!.objectId!){
//                    friend.remove(at: x)
//                }
//            }
//        }
//        user!["friends"] = friend
//        user!.saveInBackground()
        
//    }
    
//    func makeFriends(user1: PFUser, user2: PFUser) {
//        var user1Data: [NSDictionary] = []
//        var user2Data: [NSDictionary] = []
//        let user1AsFriend: NSDictionary = ["id" : "\(user1.objectId!)", "type" : 2]
//        let user2AsFriend: NSDictionary = ["id" : "\(user2.objectId!)", "type" : 2]
//        if let user1Friends = user1["friends"] as? [NSDictionary] {
//            user1Data = user1Friends
//            user1Data.append(user2AsFriend)
//        } else {
//            user1Data.append(user2AsFriend)
//        }
//        if let user2Friends = user2["friends"] as? [NSDictionary] {
//            user2Data = user2Friends
//            user2Data.append(user1AsFriend)
//        } else {
//            user2Data.append(user1AsFriend)
//        }
//        user1["friends"] = user1Data
//        user2["friends"] = user2Data
//        user1.saveInBackground()
//        user2.saveInBackground()
//    }
    
}
