//
//  SignUpViewController.swift
//  FindMe
//
//  Created by William Tong on 12/31/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    var user: PFUser = PFUser.current()!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
