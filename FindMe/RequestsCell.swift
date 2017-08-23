//
//  RequestsCell.swift
//  FindMe
//
//  Created by William Tong on 1/13/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit

class RequestsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    var acceptFunc: (() -> (Void))!
    var rejectFunc: (() -> (Void))!

    @IBAction func acceptRequest(_ sender: Any) {
        acceptFunc()
    }
    @IBAction func rejectRequest(_ sender: Any) {
        rejectFunc()
    }

    func setAcceptFunction(_ function: @escaping () -> Void) {
        self.acceptFunc = function
    }
    func setRejectFunction(_ function: @escaping () -> Void) {
        self.rejectFunc = function
    }
}
