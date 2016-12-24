//
//  PFLoginViewController.swift
//  FindMe
//
//  Created by William Tong on 9/3/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import ParseUI

class PFLoginViewController: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.text = "All Custom!"
        label.sizeToFit()
        logInView?.logo = label
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
