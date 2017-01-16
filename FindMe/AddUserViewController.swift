//
//  AddUserViewController.swift
//  FindMe
//
//  Created by William Tong on 1/3/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import Parse

class AddUserViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    var user = PFUser.current()

    var searchController: UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    
    var friendBook: [PFObject]?
    var userDatabase: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150

        // Do any additional setup after loading the view.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        if let friendsData = user?["friends"] as? [NSDictionary] {
            for friend in friendsData {
                if let friendID = friend["id"] as? String {
                    print("friend")
                    print(friendID)
                    
                }
            }
        }
        
//        let query = PFUser.query()
//        query!.whereKeyExists("phone")
//        query!.order(byAscending: "username")
//        query!.findObjectsInBackground(block: { (objects, error) in
//            if error == nil {
//                // The find succeeded.
//                // Do something with the found objects
//                if let objects = objects {
//                    for object in objects {
//                        //print(object)
//                        self.friendQueryBook.append(object)
//                        self.queryBook.append(object)
//                    }
//                }
//            } else {
//                // Log details of the failure
//                print("Error: \(error!) \(error!.localizedDescription)")
//            }
//        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addUser(_ sender: Any) {
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            
        }
    }
    
    var person: PFObject?
    
    func addByUsername(username:String, completionHandler: @escaping (_ success:Bool) -> Void){
        let query = PFUser.query()
        query!.whereKeyExists("username")
        query!.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        if(object["username"] as? String == username){
                            
                            completionHandler(true)
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.localizedDescription)")
            }
        })
    }
    
    func addToFriends(){
        
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userDatabase != nil {
            return userDatabase!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendsIdentifier", for: indexPath as IndexPath) as! AddUserCell
        let currentContact = userDatabase?[indexPath.row]
        //cell.usernameLabel.text = currentContact
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
