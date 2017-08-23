//
//  AddUserCell.swift
//  FindMe
//
//  Created by William Tong on 1/11/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit

class AddUserCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var requestFunc: (() -> (Void))!
    
    @IBAction func sendRequest(_ sender: Any) {
        requestFunc()
    }
    
    func setFunction(_ function: @escaping () -> Void) {
        self.requestFunc = function
    }
}
