//
//  RequestsCell.swift
//  FindMe
//
//  Created by William Tong on 1/13/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit

class RequestsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
//    var user = PFUser.current()
//    var otherUser: PFUser!
//    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func acceptRequest(_ sender: Any) {
        print("HELLO")
//        PFCloud.callFunction(inBackground: "acceptFriendRequest", withParameters: ["currentUserID": "\(user!.objectId!)", "userID" : otherUser.objectId!]) { (success, error) in
//            print("requesting friend")
//            if ( error == nil) {
//                print("success")
//                print(success.debugDescription)
//                do {
//                    try PFUser.current()!.fetch()
//                }
//                catch _ {
//                    print("didn't work")
//                }
//            }
//            else if (error != nil) {
//                print(error.debugDescription)
//            }
//        }
        if let tableView = superview?.superview as? UITableView {
            tableView.reloadData()
        }

    }
    @IBAction func denyRequest(_ sender: Any) {
        
    }
}
