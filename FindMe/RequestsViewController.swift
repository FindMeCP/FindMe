//
//  RequestsViewController.swift
//  FindMe
//
//  Created by William Tong on 1/13/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var requestBook: [User] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("friend requests")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.navigationItem.title = "Friend Requests"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 150
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Friend Requests"
        
        FriendsAPI.instance.addRequestObserver {
            print("Getting request observer")
            FriendsAPI.instance.requestList.sort { $0.name < $1.name }
            self.requestBook = FriendsAPI.instance.requestList
            if(self.requestBook.count == 0) {
                // add friends!
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        FriendsAPI.instance.removeRequestObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requestBook.count == 0 {
            emptyTableView.isHidden = false
        } else {
            emptyTableView.isHidden = true
        }
        return requestBook.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsIdentifier", for: indexPath as IndexPath) as! RequestsCell
        let requestUser = requestBook[indexPath.row]
        cell.nameLabel.text = requestUser.name
        let tabItems = self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabItems?[1] as! UITabBarItem
        cell.setAcceptFunction {
            let id = requestUser.id
            FriendsAPI.instance.acceptFriendRequest(id!, { (completion) in
                self.requestBook.remove(at: indexPath.row)
                if(self.requestBook.count > 0){
                    tabItem.badgeValue = String(self.requestBook.count)
                }
                self.tableView.reloadData()
            })
        }
        cell.setRejectFunction {
            let id = requestUser.id
            FriendsAPI.instance.rejectFriendRequest(id!, { (completion) in
                self.requestBook.remove(at: indexPath.row)
                if(self.requestBook.count > 0){
                    tabItem.badgeValue = String(self.requestBook.count)
                }
                self.tableView.reloadData()
            })
        }

        return cell
    }
}
