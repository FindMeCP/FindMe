//
//  User.swift
//  FindMe
//
//  Created by William Tong on 7/15/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import Foundation

class User {

    var id: String!
    var name: String!
    var email: String!
    var coordinates: (Double, Double)!
    var requests: [[String:Bool]]!
    var friends: [[String:Bool]]!
    var follow: String!
    var tracking: Bool!
    
    init(userID: String, userName: String, userEmail: String,  userCoordinates: (Double, Double), userRequests: [[String:Bool]]?,userFriends: [[String:Bool]]?,  userFollow: String?, userTracking: Bool = true) {
        self.id = userID
        self.name = userName
        self.email = userEmail
        self.coordinates = userCoordinates
        self.friends = userFriends
        self.requests = userRequests
        self.follow = userFollow
        self.tracking = userTracking
    }
    
}
