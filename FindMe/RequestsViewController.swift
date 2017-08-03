//
//  RequestsViewController.swift
//  FindMe
//
//  Created by William Tong on 1/13/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
//    var user = PFUser.current()
    var friendRequestIDs: [String] = []
//    var friendRequests: [PFObject] = []
    let friendRequestType = 1
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("friend requests")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
//        if let friendRequestIDs = user!["requests"] as? [String] {
//            print("FRIEND REQUESTS")
//            print(friendRequestIDs)
//            self.friendRequestIDs = friendRequestIDs
//            let query = PFUser.query()
//            query!.whereKeyExists("phone")
//            query!.order(byAscending: "username")
//            query!.findObjectsInBackground(block: { (objects, error) in
//                if error == nil {
//                    // The find succeeded.
//                    // Do something with the found objects
//                    if let objects = objects {
//                        for object in objects {
//                            for request in self.friendRequestIDs {
//                                if(object.objectId == request){
//                                    self.friendRequests.append(object)
//                                }
//                            }
//                        }
//                        self.tableView.reloadData()
//                    }
//                } else {
//                    // Log details of the failure
//                    print("Error: \(error!) \(error!.localizedDescription)")
//                }
//            })
//        }
        
//        self.navigationController?.setNavigationBarHidden(false, animated: false)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
//        return friendRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsIdentifier", for: indexPath as IndexPath) as! RequestsCell
//        print(friendRequests[indexPath.row])
//        let currentContact = friendRequests[indexPath.row] as? PFUser
//        cell.nameLabel.text = currentContact?.username
//        cell.otherUser = currentContact
        return cell
    }


}
