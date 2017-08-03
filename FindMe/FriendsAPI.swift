//
//  FriendsAPI.swift
//  FindMe
//
//  Created by William Tong on 7/15/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit

class FriendsAPI {
    
    static let system = FriendsAPI()
    
    // MARK: - Firebase references
    let BASE_REF = FIRDatabase.database().reference()
    /* The user Firebase reference */
    let USER_REF = FIRDatabase.database().reference().child("users")
    
    /** The Firebase reference to the current user tree */
    var CURRENT_USER_REF: FIRDatabaseReference {
        let id = FIRAuth.auth()?.currentUser!.uid
        return USER_REF.child("\(id!)")
    }
    
    /** The Firebase reference to the current user's friend tree */
    var CURRENT_USER_FRIENDS_REF: FIRDatabaseReference {
        return CURRENT_USER_REF.child("friends")
    }
    
    /** The Firebase reference to the current user's friend request tree */
    var CURRENT_USER_REQUESTS_REF: FIRDatabaseReference {
        return CURRENT_USER_REF.child("requests")
    }
    
    /** The current user's id */
    var CURRENT_USER_ID: String {
        let id = FIRAuth.auth()?.currentUser!.uid
        return id!
    }
    
    
    func getUserObject(snapshot: FIRDataSnapshot) -> User{
        let id = snapshot.key
        let name = snapshot.childSnapshot(forPath: "name").value as! String
        let email = snapshot.childSnapshot(forPath: "email").value as! String
        
        var coordinates: (Double, Double) = (0,0)
        if let latitude = snapshot.childSnapshot(forPath: "coordinates").childSnapshot(forPath: "latitude").value as? Double {
            if let longitude = snapshot.childSnapshot(forPath: "coordinates").childSnapshot(forPath: "longitude").value as? Double {
                coordinates = (latitude, longitude)
            }
        }
        var requests: [[String:Bool]] = []
        if let requestsValue = snapshot.childSnapshot(forPath: "friends").value as? [[String:Bool]] {
            requests = requestsValue
        }
        var friends: [[String:Bool]] = []
        if let friendsValue = snapshot.childSnapshot(forPath: "friends").value as? [[String:Bool]] {
            friends = friendsValue
        }
        var follow = ""
        if let followValue = snapshot.childSnapshot(forPath: "follow").value as? String {
            follow = followValue
        }
        var tracking = true
        if let trackingValue = snapshot.childSnapshot(forPath: "tracking").value as? Bool {
            tracking = trackingValue
        }
        
        return User(userID: id, userName: name, userEmail: email,  userCoordinates: coordinates, userRequests: requests,userFriends: friends, userFollow: follow, userTracking: tracking)
    }
    
    /** Gets the current User object for the specified user id */
    func getCurrentUser(_ completion: @escaping (User) -> Void) {
        CURRENT_USER_REF.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let user = self.getUserObject(snapshot: snapshot)
            completion(user)
        })
    }
    /** Gets the User object for the specified user id */
    func getUser(_ userID: String, completion: @escaping (User) -> Void) {
        USER_REF.child(userID).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let user = self.getUserObject(snapshot: snapshot)
            completion(user)
        })
    }
    
    
    // MARK: - Account Related
    
    /**
     Creates a new user account with the specified email and password
     - parameter completion: What to do when the block has finished running. The success variable
     indicates whether or not the signup was a success
     */
    func createEmailAccount(_ email: String, password: String, name: String, completion: @escaping (_ success: Bool) -> Void) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if (error == nil) {
                // Success
                var userInfo = [String: AnyObject]()
                userInfo = ["email": email as AnyObject, "name": name as AnyObject]
                self.CURRENT_USER_REF.setValue(userInfo)
                completion(true)
            } else {
                // Failure
                completion(false)
            }
            
        })
    }
    
    func loginFBAccount(_ credentials: FIRAuthCredential, completion: @escaping (_ success: Bool) -> Void) {
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Error with FB user: ", error ?? " ")
                return
            }
            print("Successfully logged in with FB User", user ?? " ")
            guard let userID = user?.uid, let name = user?.displayName, let email = user?.email else {
                return
            }
            let ref = FIRDatabase.database().reference(fromURL: "https://findme-e7ff6.firebaseio.com/")
            ref.child("users").child(userID).observeSingleEvent (of: FIRDataEventType.value, with: { (snapshot) in
                if snapshot.exists() {
                    // if user exists just log in
                    completion(true)
                } else {
                    // otherwise, create user
                    ref.child("users").child(userID).child("name").setValue(name)
                    ref.child("users").child(userID).child("email").setValue(email)
                    ref.child("users").child(userID).child("follow").setValue("")
                    ref.child("users").child(userID).child("tracking").setValue(true)
                    completion(true)
                }
            })
        })
    }

    
    /**
     Logs in an account with the specified email and password
     
     - parameter completion: What to do when the block has finished running. The success variable
     indicates whether or not the login was a success
     */
    func loginEmailAccount(_ email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if (error == nil) {
                // Success
                completion(true)
            } else {
                // Failure
                completion(false)
                print(error!)
            }
            
        })
    }
    
    /** Logs out an account */
    func logoutAccount() {
        FBSDKLoginManager().logOut()
        try! FIRAuth.auth()?.signOut()
    }
    
    
    
    // MARK: - Request System Functions
    
    /** Sends a friend request to the user with the specified id */
    func sendRequestToUser(_ userID: String) {
        USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).setValue(true)
    }
    
    /** Unfriends the user with the specified id */
    func removeFriend(_ userID: String) {
        CURRENT_USER_REF.child("friends").child(userID).removeValue()
        USER_REF.child(userID).child("friends").child(CURRENT_USER_ID).removeValue()
    }
    
    /** Accepts a friend request from the user with the specified id */
    func acceptFriendRequest(_ userID: String) {
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(true)
        USER_REF.child(userID).child("friends").child(CURRENT_USER_ID).setValue(true)
        USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).removeValue()
    }
    
    // MARK: - Location System Functions
    /** Follows a friend **/
    func followUser(_ userID: String, _ completion: @escaping (String) -> Void) {
        CURRENT_USER_FRIENDS_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value(forKey: userID) != nil {
                self.CURRENT_USER_REF.child("follow").setValue(userID)
            }
        })
    }
    
    /** Gets coordinates that current user is following */
    func getUserLocation(_ userID: String, _ completion: @escaping (Float, Float) -> Void) {
        USER_REF.child(userID).child("coordinates").observe(.value, with: { (snapshot) in
            guard let latitude: Float = snapshot.childSnapshot(forPath: "latitude").value as? Float else {
                return
            }
            guard let longitude: Float = snapshot.childSnapshot(forPath: "longitude").value as? Float else { return
            }
            completion(latitude,longitude)
        })
    }
    
    /** Gets coordinates that current user is following */
    func updateUserLocation(_ userID: String, coordinates: (Double, Double)) {
        print("updating UserLocation")
        print(userID)
        USER_REF.child(userID).child("coordinates").child("latitude").setValue(coordinates.0)
        USER_REF.child(userID).child("coordinates").child("longitude").setValue(coordinates.1)
    }
    
    /** Change Tracking */
    func changeTracking(_ track: Bool) {
        if(track) {
            CURRENT_USER_REF.child("tracking").setValue(true)
        } else {
//            CURRENT_USER_REF.child("follow").setValue("")
            CURRENT_USER_REF.child("tracking").setValue(false)
        }
    }
    
    
    // MARK: - All users
    /** The list of all users */
    var userList = [User]()
    /** Adds a user observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addUserObserver(_ update: @escaping () -> Void) {
        FriendsAPI.system.USER_REF.observe(FIRDataEventType.value, with: { (snapshot) in
            self.userList.removeAll()
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let email = child.childSnapshot(forPath: "email").value as! String
                if email != FIRAuth.auth()?.currentUser?.email! {
                    let user = self.getUserObject(snapshot: child)
                    self.userList.append(user)
                }
            }
            update()
        })
    }
    /** Removes the user observer. This should be done when leaving the view that uses the observer. */
    func removeUserObserver() {
        USER_REF.removeAllObservers()
    }
    
    
    
    // MARK: - All friends
    /** The list of all friends of the current user. */
    var friendList = [User]()
    /** Adds a friend observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addFriendObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_FRIENDS_REF.observe(FIRDataEventType.value, with: { (snapshot) in
            self.friendList.removeAll()
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.friendList.append(user)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend observer. This should be done when leaving the view that uses the observer. */
    func removeFriendObserver() {
        CURRENT_USER_FRIENDS_REF.removeAllObservers()
    }
    
    
    
    // MARK: - All requests
    /** The list of all friend requests the current user has. */
    var requestList = [User]()
    /** Adds a friend request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addRequestObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_REQUESTS_REF.observe(FIRDataEventType.value, with: { (snapshot) in
            self.requestList.removeAll()
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.requestList.append(user)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend request observer. This should be done when leaving the view that uses the observer. */
    func removeRequestObserver() {
        CURRENT_USER_REQUESTS_REF.removeAllObservers()
    }
    
}
