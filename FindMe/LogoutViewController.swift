//
//  LogoutViewController.swift
//  FindMe
//
//  Created by Jordi Turner on 3/21/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

class LogoutViewController: UIViewController {

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            settingsButton.target = self.revealViewController()
            settingsButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
