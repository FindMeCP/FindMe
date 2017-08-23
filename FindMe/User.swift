//
//  User.swift
//  FindMe
//
//  Created by William Tong on 7/15/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

class User: Hashable, CustomStringConvertible {

    var id: String!
    var name: String!
    var email: String!
    var timestamp: TimeInterval
    var coordinates: (Double, Double)!
    var requests: [[String:Bool]]!
    var friends: [[String:Bool]]!
    var follow: String!
    var tracking: Bool!
    
    var hashValue: Int {
        return id.hashValue
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var description: String {
        return id + ": " + name
    }
    
    init(userID: String, userName: String, userEmail: String, userTimestamp: TimeInterval, userCoordinates: (Double, Double), userRequests: [[String:Bool]]?,userFriends: [[String:Bool]]?,  userFollow: String?, userTracking: Bool = true) {
        self.id = userID
        self.name = userName
        self.email = userEmail
        self.coordinates = userCoordinates
        self.timestamp = userTimestamp
        self.friends = userFriends
        self.requests = userRequests
        self.follow = userFollow
        self.tracking = userTracking
    }
    
}
