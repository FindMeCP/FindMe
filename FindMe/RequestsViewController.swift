//
//  RequestsViewController.swift
//  FindMe
//
//  Created by William Tong on 1/13/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import Parse

class RequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user = PFUser.current()
    var friendRequestIDs: [String] = []
    var friendRequests: [PFObject] = []
    let friendRequestType = 1
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("friend requests")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Do any additional setup after loading the view.
        if let friendsData = user!["friends"] as? [NSDictionary] {
            for friend in friendsData {
                print(friend)
                if let friendType = friend["type"] as? Int {
                    if friendType == friendRequestType {
                        if let friendID = friend["id"] as? String {
                            print("friend")
                            print(friendID)
                            friendRequestIDs.append(friendID)
                        }
                    }
                }
            }
        }
        
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
                        for request in self.friendRequestIDs {
                            if(object.objectId == request){
                                self.friendRequests.append(object)
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.localizedDescription)")
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsIdentifier", for: indexPath as IndexPath) as! RequestsCell
        print(friendRequests[indexPath.row])
        let currentContact = friendRequests[indexPath.row] as? PFUser
        cell.nameLabel.text = currentContact?.username
        return cell
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
