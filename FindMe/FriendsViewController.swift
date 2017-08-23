//
//  FriendsViewController.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
//  Copyright © 2016 William Tong. All rights reserved.
//
import UIKit


@available(iOS 9.0, *)
class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableView: UIView!
    
    var friendBook: [User]! = []    //Friends
    var filteredFriendBook: [User]! = []
    var searchController: UISearchController!
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("friend view controller")
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.navigationItem.title = "Follow Friends"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 150

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar

        FriendsAPI.instance.getCurrentUser { (user) in
            self.currentUser = user
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        let point = CGPoint(x: 0,y: self.searchController.searchBar.frame.size.height)
        self.tableView.setContentOffset(point, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.navigationItem.title = "Follow Friends"

        FriendsAPI.instance.addFriendObserver {
            FriendsAPI.instance.friendList.sort { $0.timestamp > $1.timestamp }
            self.friendBook = FriendsAPI.instance.friendList
            self.filteredFriendBook = self.friendBook
            self.tableView.reloadData()
        }
        
        
        let tabItems = self.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabItems?[1] as! UITabBarItem
        FriendsAPI.instance.addRequestObserver {
            if(FriendsAPI.instance.requestList.count > 0){
                tabItem.badgeValue = String(FriendsAPI.instance.requestList.count)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        FriendsAPI.instance.removeFriendObserver()
        FriendsAPI.instance.removeRequestObserver()
        print("VIEW DID DISAPPEAR")
    }
    
   
    /*
     *   tableView methods to control for both tableViews
     */


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredFriendBook.count == 0 {
            emptyTableView.isHidden = false
        } else {
            emptyTableView.isHidden = true
        }
        return filteredFriendBook.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsIdentifier", for: indexPath as IndexPath) as! FriendsCell
        let friendUser = filteredFriendBook[indexPath.row]
        cell.nameLabel.text = friendUser.name
        if currentUser != nil && currentUser!.follow == friendUser.id {
            cell.followButton.setImage(UIImage(named: "PinkCheck"), for: .normal)
        }else {
            cell.followButton.setImage(UIImage(named: "PinkAdd"), for: .normal)
        }
        let date = NSDate(timeIntervalSince1970: friendUser.timestamp)
        let interval = date.timeIntervalSinceNow * -1
        cell.user = friendUser
        cell.setFollowFunction {
            let id = friendUser.id
            FriendsAPI.instance.followUser(id!, { (completion) in
                self.currentUser?.follow = id
                self.tableView.reloadData()
            })
        }
        cell.setActivity(timeInterval: interval)
        print("TIME INTERVAL \(interval)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let friendUser = filteredFriendBook[indexPath.row]
            FriendsAPI.instance.removeFriend(friendUser.id)
            print("deleted friend")
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredFriendBook = searchText.isEmpty ? friendBook : friendBook.filter({(user: User) -> Bool in
                return (user.name).range(of: searchText, options: .caseInsensitive) != nil
            })

            tableView.reloadData()
        }
    }
}

