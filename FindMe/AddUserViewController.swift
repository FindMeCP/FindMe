//
//  AddUserViewController.swift
//  FindMe
//
//  Created by William Tong on 1/3/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit

class AddUserViewController: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    

    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    
    var userBook: [User] = []
    var filteredUserBook: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("add user controller")
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.navigationItem.title = "Add a Friend!"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 150

        // Do any additional setup after loading the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.navigationItem.title = "Add a Friend!"
        
        FriendsAPI.instance.addOtherUserObserver {
            print("Getting user observer")
            FriendsAPI.instance.otherUserList.sort { $0.name < $1.name }
            self.userBook = FriendsAPI.instance.otherUserList
            self.filteredUserBook = self.userBook
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        FriendsAPI.instance.removeOtherUserObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUserBook.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendsIdentifier", for: indexPath as IndexPath) as! AddUserCell
        let user = filteredUserBook[indexPath.row]
        cell.usernameLabel.text = user.name
        cell.setFunction {
            let id = user.id
            
            FriendsAPI.instance.sendRequestToUser(id!, { (delivered) in
                var message = "Successfully Delivered Request to \(user.name!)!"
                if(!delivered) {
                    message = "Request to \(user.name!) is already pending."
                }
                let requestAlert = UIAlertController(title: "Friend Request", message: message, preferredStyle: .alert)
                requestAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    requestAlert .dismiss(animated: true, completion: nil)
                }))
                self.present(requestAlert, animated: true, completion: nil)
            })
            self.tableView.reloadData()
            
            
        }
        return cell
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredUserBook = searchText.isEmpty ? userBook : userBook.filter({(user: User) -> Bool in
                return (user.name).range(of: searchText, options: .caseInsensitive) != nil
            })
            tableView.reloadData()
        }
    }

}
