//
//  MainViewController.swift
//  FindMe
//
//  Created by William Tong on 3/8/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import Parse
import MapKit

//more google help http://www.appcoda.com/google-maps-api-tutorial/
//contacts helps http://appcoda.com/ios-contacts-framework/


@available(iOS 9.0, *)
class MainViewController: UIViewController, CLLocationManagerDelegate{
    
    // views for all three maps (2 split screen maps for split mode, 1 full screen for shared and solo modes)
    @IBOutlet weak var firstMapTitle: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var secondMapTitle: UILabel!
    @IBOutlet weak var mapView1: GMSMapView!
    @IBOutlet weak var mapView2: GMSMapView!
    @IBOutlet weak var mapViewFull: GMSMapView!
    @IBOutlet weak var mapViewArea: UIView!
    @IBOutlet weak var mapViewArea2: UIView!
    @IBOutlet weak var mapModeSlider: UISlider!
    
    // views for menuBar and menuBar animation
    @IBOutlet weak var grayoutView: UIButton!
    @IBOutlet weak var menuBarView: UIView!
    @IBOutlet weak var menuConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var trackingButton: UISwitch!
    
    // constants for mapView modes
    let splitMode: Float = 0
    let sharedMode: Float = 1
    let soloMode: Float = 2
    
    // constant for map zoom setting
    let zoomSetting: Float = 13
    
    // variables to manage location
    let locationManager = CLLocationManager()
    var locationMarker: GMSMarker!
    
    // Parse User objects for current user and user being followed
    let user = PFUser.currentUser()
    var otherUser: PFObject!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.hidden = false
        if user != nil{
            loadFollowedUser()
        }
        
        locationManager.delegate = self
        secondMapTitle.text = "\((user!.username)!)"
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .NotDetermined:
            print("not determined")
        case .AuthorizedWhenInUse:
            print("authorized when in use")
        case .AuthorizedAlways:
            print("authorized always")
            locationManager.startUpdatingLocation()
            if user!["follow"] as! String != ""{
               NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(MainViewController.timedPinUpdate), userInfo: nil, repeats: true)
            }
        case .Restricted:
            print("restricted")
        // restricted by e.g. parental controls. User can't enable Location Services
        case .Denied:
            print("not authorized")
            // user denied your app access to Location Services, but can grant access from Settings.app
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        loadingView.hidden = false
        loadFollowedUser()
        
        if let userTracking = user!["tracking"] as? Bool {
            if (userTracking) {
                trackingButton.on = true
                track = true
            }else{
                trackingButton.on = false
                track = false
            }
        }else{
            trackingButton.on = false
            track = false
        }
        
        usernameLabel.text = user!.username
        
    }
    
    // retrieves the person being followed by current user (if any) and assigns to global variable otherUser
    func loadFollowedUser() {
        if let otherUserPhone = user!["follow"] as? String {
            if otherUserPhone != "" {
                
                // query using the phone number of the person that user is following
                let query = PFUser.query()
                query!.whereKey("phone", equalTo: otherUserPhone)
                query!.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        if let objects = objects {
                            for object in objects {
                                self.otherUser = object
                            }
                        }
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                    
                    if let trackOtherUser = self.otherUser["tracking"] as? Bool {
                        if(trackOtherUser){
                            let otherUserCoordinates = self.loadOtherUserData() as CLLocationCoordinate2D!
                            self.setuplocationMarker(otherUserCoordinates)
                            let friendName = self.otherUser["username"]
                            self.firstMapTitle.text = "\(friendName)"
                        }else{
                            self.firstMapTitle.text = "Friend name"
                        }
                    }
                    self.mapMode()
                    self.loadingView.hidden = true
                }
            }
        }
        else {
            firstMapTitle.text = "Friend Name"
            mapMode()
            loadingView.hidden = true
            
            if locationMarker != nil {
                locationMarker.map = nil
            }
        }
    }
    

    
    
    // methods to control the map being displayed
    func mapMode () {
        if (mapModeSlider.value == splitMode){
            setSplitMode()
        }
        else if (mapModeSlider.value == sharedMode){
            setSharedMode()
        }
        else if (mapModeSlider.value == soloMode){
            setSoloMode()
        }
    }
    
    func setSplitMode() {
        mapViewArea2.hidden = true;
        mapView1.myLocationEnabled = true
        mapView1.settings.myLocationButton = true
        mapView2.myLocationEnabled = true
        mapView2.settings.myLocationButton = true
        if user!["follow"] as? String != ""{
            print("reached this point - following")
            let otherUserCoordinates = loadOtherUserData()
            mapView1.animateToZoom(zoomSetting)
            mapView1.animateToLocation(otherUserCoordinates)
            setuplocationMarker(otherUserCoordinates)
            if let userCoordinates = locationManager.location?.coordinate {
                mapView2.animateToZoom(zoomSetting)
                mapView2.animateToLocation(userCoordinates)
            }
        }
        else {
            print("reached this point - no following")
            if let userCoordinates = locationManager.location?.coordinate {
                mapView1.animateToZoom(zoomSetting)
                mapView1.animateToLocation(userCoordinates)
                mapView2.animateToZoom(zoomSetting)
                mapView2.animateToLocation(userCoordinates)
            }
        }
    }
    
    func setSharedMode() {
        mapViewArea2.hidden = false;
        mapViewFull.myLocationEnabled = true
        mapViewFull.settings.myLocationButton = true
        if let userCoordinates = locationManager.location?.coordinate {
            if user!["follow"] as? String != ""{
                let otherUserCoordinates = loadOtherUserData()
                let path = GMSMutablePath()
                path.addCoordinate(userCoordinates)
                path.addCoordinate(otherUserCoordinates)
                let bounds = GMSCoordinateBounds(path: path)
                mapViewFull.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds,withPadding: 50))
                setuplocationMarker(otherUserCoordinates)
            }
            else {
                mapViewFull.animateToZoom(zoomSetting)
                mapViewFull.animateToLocation(userCoordinates)
            }
        }
    }
    
    func setSoloMode() {
        mapViewArea2.hidden = false;
        mapViewFull.myLocationEnabled = true
        mapViewFull.settings.myLocationButton = true
        if user!["follow"] as? String != ""{
            let otherUserCoordinates = loadOtherUserData()
            mapViewFull.animateToZoom(zoomSetting)
            mapViewFull.animateToLocation(otherUserCoordinates)
            setuplocationMarker(otherUserCoordinates)
        }
        else {
            if let userCoordinates = locationManager.location?.coordinate {
                mapViewFull.animateToZoom(zoomSetting)
                mapViewFull.animateToLocation(userCoordinates)
            }
        }
    }
    
    
    // sets location marker for other user
    func setuplocationMarker(coordinate: CLLocationCoordinate2D) {
        if locationMarker != nil {
            locationMarker.map = nil
        }
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.title = "Username"
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.flat = false
        locationMarker.snippet = "Time posted"
        if (mapModeSlider.value == splitMode){
            locationMarker.map = mapView1
        }
        else if (mapModeSlider.value > splitMode){
            locationMarker.map = mapViewFull
        }
    }
    
    // sets location data for other user
    func loadOtherUserData() -> CLLocationCoordinate2D {
        var Lat = 0.0
        var Long = 0.1
        
        /*
        *   FIXME
        */
        
        if otherUser != nil {
            if otherUser["latitude"] != nil{
                Lat = otherUser["latitude"] as! Double
                Long = otherUser["longitude"] as! Double
                
            } else{
                print("If let not working")
            }
        }
        return CLLocationCoordinate2DMake(Lat, Long)
    }
    
    // checks to see if current user's tracking is turned on.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let tracking = user!["tracking"] as? Bool{
            if(tracking){
                user!["latitude"] = locationManager.location?.coordinate.latitude
                user!["longitude"] = locationManager.location?.coordinate.longitude
                ///ADD USER TIME
                user!.saveInBackground()
            }
        }
    }
    
    func timedPinUpdate()
    {
            if let otherUserPhone = user!["follow"] as? String{
                if otherUserPhone != ""{
                    let query = PFUser.query()
                    query!.whereKey("phone", equalTo: otherUserPhone)
                    query!.findObjectsInBackgroundWithBlock {
                        (objects: [PFObject]?, error: NSError?) -> Void in
                
                        if error == nil {
                            if let objects = objects {
                                for object in objects {
                                    self.otherUser = object
                                }
                            }
                            let otherUserCoordinates = self.loadOtherUserData() as CLLocationCoordinate2D!
                            self.setuplocationMarker(otherUserCoordinates)
                        } else {
                            print("Error: \(error!) \(error!.userInfo)")
                        }
                    }
                }
            }
    }
    
    // changes mode displayed (split, shared, or solo) based on slider
    @IBAction func sliderLetGo(sender: UISlider) {
        sender.setValue(Float(roundf(sender.value)), animated: false)
        mapMode()
    }
    
    // controls actions on press of return buttons on map (should return to current place)
    @IBAction func onMapFullReturn(sender: AnyObject) {
        mapMode()
    }
    
    @IBAction func onMap1Return(sender: AnyObject) {
        if user!["follow"] as? String != "" {
            let otherUserCoordinates = loadOtherUserData()
            mapView1.animateToZoom(zoomSetting)
            mapView1.animateToLocation(otherUserCoordinates)
            setuplocationMarker(otherUserCoordinates)
        }
        else {
            if let userCoordinates = locationManager.location?.coordinate {
                mapView1.animateToZoom(zoomSetting)
                mapView1.animateToLocation(userCoordinates)
            }
        }
        
    }
    
    @IBAction func onMap2Return(sender: AnyObject) {
        if let userCoordinates = locationManager.location?.coordinate {
            mapView2.animateToZoom(zoomSetting)
            mapView2.animateToLocation(userCoordinates)
        }
    }
    
    // methods to manage presentation of menuView
    @IBAction func onMenu(sender: AnyObject) {
        showMenu()
    }
    
    @IBAction func onMenuFindMe(sender: AnyObject) {
        hideMenu()
    }
    
    @IBAction func touchToMenu(sender: AnyObject) {
        hideMenu()
    }
    
    func showMenu(){
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
            self.menuBarView.center.x += self.menuBarView.frame.width
            self.grayoutView.alpha = 0.5
            
            }, completion: { finished in
                print("menu bar opened!")
        })
    }
    
    func hideMenu(){
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
            self.menuBarView.center.x -= self.menuBarView.frame.width
            self.grayoutView.alpha = 0
            }, completion: { finished in
                print("menu bar closed!")
        })
        viewDidAppear(false)
    }

    var track: Bool?
    
    @IBAction func changeTracking(sender: AnyObject) {
        if(track!){
            track = false
            user!["tracking"] = false
            user!["follow"] = ""
            user!.saveInBackground()
            print("false")
        }else{
            track = true
            user!["tracking"] = true
            user!.saveInBackground()
            print("true")
        }
    }

    
}
