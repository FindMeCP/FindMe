//
//  AddUserCell.swift
//  FindMe
//
//  Created by William Tong on 1/11/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit

class AddUserCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
//    var user = PFUser.current()
//    var otherUser: PFUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
//    @IBAction func sendRequest(_ sender: Any) {
//        sendFriendRequest(otherUser: self.otherUser)
//    }
//    
//    func sendFriendRequest(otherUser: PFUser){
//        if user != nil && otherUser != nil{
//            print("USER ID")
//            print(user!.objectId!)
//            PFCloud.callFunction(inBackground: "friendRequest", withParameters: ["currentUserID": "\(user!.objectId!)", "userID" : otherUser.objectId!]) { (success, error) in
//                print("requesting friend")
//                if ( error == nil) {
//                    print("success")
//                    print(success.debugDescription)
//                }
//                else if (error != nil) {
//                    print(error.debugDescription)
//                }
//                //                print(
//            }
//        }else {
//            print("one or more users are nil")
//        }
//        
//    }

}
