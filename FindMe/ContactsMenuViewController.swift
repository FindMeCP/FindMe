//
//  ContactsMenuViewController.swift
//  FindMe
//
//  Created by William Tong on 1/13/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit

class ContactsMenuViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var proPic: UIImageView!
    
//    var currentUser = PFUser.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        usernameLabel.text = currentUser?.username
        // Do any additional setup after loading the view.
        proPic.layer.cornerRadius = 8
        proPic.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
