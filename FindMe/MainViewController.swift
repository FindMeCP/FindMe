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
    @IBOutlet weak var firstMapTitle: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var secondMapTitle: UILabel!
    @IBOutlet weak var mapView1: GMSMapView!
    @IBOutlet weak var mapView2: GMSMapView!
    @IBOutlet weak var mapViewFull: GMSMapView!
    @IBOutlet weak var mapViewArea: UIView!
    @IBOutlet weak var mapViewArea2: UIView!
    @IBOutlet weak var mapModeSlider: UISlider!
    
    @IBOutlet weak var grayoutView: UIButton!
    @IBOutlet weak var menuBarView: UIView!
    @IBOutlet weak var menuConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var trackingButton: UISwitch!
    
    
    
    var contactsViewController = ContactsViewController()
    let locationManager = CLLocationManager()
    let user = PFUser.currentUser()
    var locationMarker: GMSMarker!
    var otherUser: PFObject!
    var otherUserPhone: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        loadingView.hidden = false
            if user!["follow"] as! String != ""{
                otherUserPhone = user!["follow"] as! String
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
                    if(self.otherUser["tracking"] as! Bool == true){
                        let otherUserCoordinates = self.loadOtherUserData() as CLLocationCoordinate2D!
                        self.setuplocationMarker(otherUserCoordinates)
                        self.mapMode()
                        self.loadingView.hidden = true
                        print("map fully loaded")
                        let friendName = self.otherUser["username"]
                        self.firstMapTitle.text = "\(friendName)"
                    }else{
                        self.firstMapTitle.text = "Friend name"
                        self.mapMode()
                        self.loadingView.hidden = true
                    }
                }
            }
            else {
                
                firstMapTitle.text = "Friend name"
                mapMode()
                loadingView.hidden = true
                if locationMarker != nil {
                    locationMarker.map = nil
                }
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
        print("View did appear")
                
        loadingView.hidden = false
        if user!["follow"] as! String != ""{
            otherUserPhone = user!["follow"] as! String
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
                if(self.otherUser["tracking"] as! Bool == true){
                    let otherUserCoordinates = self.loadOtherUserData() as CLLocationCoordinate2D!
                    self.setuplocationMarker(otherUserCoordinates)
                    self.mapMode()
                    self.loadingView.hidden = true
                    print("map fully loaded")
                    let friendName = self.otherUser["username"]
                    self.firstMapTitle.text = "\(friendName)"
                }else{
                    self.firstMapTitle.text = "Friend name"
                    self.mapMode()
                    self.loadingView.hidden = true
                }
            }
        }
        else {
            firstMapTitle.text = "Friend name"
            mapMode()
            loadingView.hidden = true
            if locationMarker != nil {
                locationMarker.map = nil
            }
        }
        if(user!["tracking"] as! Bool == true){
            trackingButton.on = true
            track = true
        }else{
            trackingButton.on = false
            track = false
        }
        usernameLabel.text = PFUser.currentUser()?.username
        
    }
    
    
    @IBAction func onMapFullReturn(sender: AnyObject) {
        mapMode()
    }
   
    @IBAction func onMap1Return(sender: AnyObject) {
        if user!["follow"] as! String != ""{
            let otherUserCoordinates = loadOtherUserData()
            mapView1.animateToZoom(13)
            mapView1.animateToLocation(otherUserCoordinates)
            setuplocationMarker(otherUserCoordinates)
        }
        else {
            if let UserCoordinates = locationManager.location?.coordinate {
                mapView1.animateToZoom(13)
                mapView1.animateToLocation(UserCoordinates)
            }
        }
        
    }
    
    @IBAction func onMap2Return(sender: AnyObject) {
        if let UserCoordinates = locationManager.location?.coordinate {
            mapView2.animateToZoom(13)
            mapView2.animateToLocation(UserCoordinates)
        }
    }
    
    @IBAction func sliderLetGo(sender: UISlider) {
        sender.setValue(Float(roundf(sender.value)), animated: false)
        mapMode()
        
    }
    
    func mapMode () {
        //let NYCoordinates = CLLocationCoordinate2DMake(40.72, -74)
        if (mapModeSlider.value == 0){
            //print("split mode")
            mapViewArea2.hidden = true;
            mapView1.myLocationEnabled = true
            mapView1.settings.myLocationButton = true
            mapView2.myLocationEnabled = true
            mapView2.settings.myLocationButton = true
            if user!["follow"] as! String != ""{
                print("reached this point - following")
                let otherUserCoordinates = loadOtherUserData()
                mapView1.animateToZoom(13)
                mapView1.animateToLocation(otherUserCoordinates)
                setuplocationMarker(otherUserCoordinates)
                if let UserCoordinates = locationManager.location?.coordinate {
                    mapView2.animateToZoom(13)
                    mapView2.animateToLocation(UserCoordinates)
                }
            }
            else {
                print("reached this point - no following")
                if let UserCoordinates = locationManager.location?.coordinate {
                    mapView1.animateToZoom(13)
                    mapView1.animateToLocation(UserCoordinates)
                    mapView2.animateToZoom(13)
                    mapView2.animateToLocation(UserCoordinates)
                }
            }
            
            
        }
        else if (mapModeSlider.value == 1){
            //print("shared mode")
            mapViewArea2.hidden = false;
            mapViewFull.myLocationEnabled = true
            mapViewFull.settings.myLocationButton = true
            if let UserCoordinates = locationManager.location?.coordinate {
                if user!["follow"] as! String != ""{
                    let otherUserCoordinates = loadOtherUserData()
                    let path = GMSMutablePath()
                    path.addCoordinate(UserCoordinates)
                    path.addCoordinate(otherUserCoordinates)
                    let bounds = GMSCoordinateBounds(path: path)
                    mapViewFull.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds,withPadding: 50))
                    setuplocationMarker(otherUserCoordinates)
                }
                else {
                    mapViewFull.animateToZoom(13)
                    mapViewFull.animateToLocation(UserCoordinates)
                }
            }
        }
        else if (mapModeSlider.value == 2){
            //print("solo mode")
            mapViewArea2.hidden = false;
            mapViewFull.myLocationEnabled = true
            mapViewFull.settings.myLocationButton = true
            if user!["follow"] as! String != ""{
                let otherUserCoordinates = loadOtherUserData()
                mapViewFull.animateToZoom(13)
                mapViewFull.animateToLocation(otherUserCoordinates)
                setuplocationMarker(otherUserCoordinates)
            }
            else {
                if let UserCoordinates = locationManager.location?.coordinate {
                    mapViewFull.animateToZoom(13)
                    mapViewFull.animateToLocation(UserCoordinates)
                }
            }
        }
    }
    
    func setuplocationMarker(coordinate: CLLocationCoordinate2D) {
        if locationMarker != nil {
            locationMarker.map = nil
        }
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.title = "Username"
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.flat = false
        locationMarker.snippet = "Time posted"
        if (mapModeSlider.value == 0){
            locationMarker.map = mapView1
        }
        else if (mapModeSlider.value > 0){
            locationMarker.map = mapViewFull
        }
    }
    
    func loadOtherUserData() -> CLLocationCoordinate2D {
        var Lat = 0.0
        var Long = 0.1
        if otherUser["latitude"] != nil{
            Lat = otherUser["latitude"] as! Double
            Long = otherUser["longitude"] as! Double
            
        } else{
            print("If let not working")
        }
        return CLLocationCoordinate2DMake(Lat, Long)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(user!["tracking"] as! Bool == true){
            user!["latitude"] = locationManager.location?.coordinate.latitude
            user!["longitude"] = locationManager.location?.coordinate.longitude
            ///ADD USER TIME
            user!.saveInBackground()
        }
    }

    
    @IBAction func onMenu(sender: AnyObject) {
        showMenu()
    }
    
    @IBAction func onMenuFindMe(sender: AnyObject) {
        hideMenu()
    }
    
    func timedPinUpdate()
    {
            if user!["follow"] as! String != ""{

                otherUserPhone = user!["follow"] as! String
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
    
    @IBAction func touchToMenu(sender: AnyObject) {
        //grayoutView.hidden = true
        hideMenu()
    }
    
    func showMenu(){
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseIn, animations: {
            self.menuBarView.center.x += self.menuBarView.frame.width
            self.grayoutView.alpha = 0.5
            
            }, completion: { finished in
                print("menu bar opened!")
        })
    }
    
    func hideMenu(){
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseIn, animations: {
            self.menuBarView.center.x -= self.menuBarView.frame.width
            self.grayoutView.alpha = 0
            }, completion: { finished in
                print("menu bar closed!")
        })
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
