//
//  MapViewController.swift
//  FindMe
//
//  Created by William Tong on 1/2/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps

//more google help http://www.appcoda.com/google-maps-api-tutorial/
//contacts helps http://appcoda.com/ios-contacts-framework/

@available(iOS 9.0, *)
class MapViewController: UIViewController, CLLocationManagerDelegate {
    
        // views for all three maps (2 split screen maps for split mode, 1 full screen for shared and solo modes)
    @IBOutlet weak var firstMapTitle: UILabel!
    @IBOutlet weak var secondMapTitle: UILabel!
    
    @IBOutlet weak var mapView1: GMSMapView!
    @IBOutlet weak var mapView2: GMSMapView!
    @IBOutlet weak var mapViewFull: GMSMapView!

    @IBOutlet weak var loadingView: UIView!
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
    let user = PFUser.current()
    var otherUser: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = false
        if user != nil{
            loadFollowedUser()
        }
        
        locationManager.delegate = self
        secondMapTitle.text = "\((user!.username)!)"
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            print("not determined")
        case .authorizedWhenInUse:
            print("authorized when in use")
        case .authorizedAlways:
            print("authorized always")
            locationManager.startUpdatingLocation()
            if user!["follow"] as! String != ""{
                Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(MapViewController.timedPinUpdate), userInfo: nil, repeats: true)
            }
        case .restricted:
            print("restricted")
        // restricted by e.g. parental controls. User can't enable Location Services
        case .denied:
            print("not authorized")
            // user denied your app access to Location Services, but can grant access from Settings.app
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadingView.isHidden = false
        loadFollowedUser()
        if let userTracking = user!["tracking"] as? Bool {
            if (userTracking) {
                trackingButton.isOn = true
                track = true
            }else{
                trackingButton.isOn = false
                track = false
            }
        }else{
            trackingButton.isOn = false
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
                query!.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        if let objects = objects {
                            for object in objects {
                                self.otherUser = object
                            }
                        }
                    } else {
                        print("Error: \(error!) \(error!.localizedDescription)")
                    }
                    
                    if let trackOtherUser = self.otherUser["tracking"] as? Bool {
                        if(trackOtherUser){
                            let otherUserCoordinates = self.loadOtherUserData() as CLLocationCoordinate2D!
                            self.setuplocationMarker(coordinate: otherUserCoordinates!)
                            let friendName = self.otherUser["username"]
                            self.firstMapTitle.text = "\(friendName)"
                        }else{
                            self.firstMapTitle.text = "Friend name"
                        }
                    }
                    self.mapMode()
                    self.loadingView.isHidden = true
                })
            }
        }
        else {
            firstMapTitle.text = "Friend Name"
            mapMode()
            loadingView.isHidden = true
            
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
        mapViewArea2.isHidden = true;
        mapView1.isMyLocationEnabled = true
        mapView1.settings.myLocationButton = true
        mapView2.isMyLocationEnabled = true
        mapView2.settings.myLocationButton = true
        if user!["follow"] as? String != ""{
            print("reached this point - following")
            let otherUserCoordinates = loadOtherUserData()
            mapView1.animate(toZoom: zoomSetting)
            mapView1.animate(toLocation: otherUserCoordinates)
            setuplocationMarker(coordinate: otherUserCoordinates)
            if let userCoordinates = locationManager.location?.coordinate {
                mapView2.animate(toZoom: zoomSetting)
                mapView2.animate(toLocation: userCoordinates)
            }
        }
        else {
            print("reached this point - no following")
            if let userCoordinates = locationManager.location?.coordinate {
                mapView1.animate(toZoom: zoomSetting)
                mapView1.animate(toLocation: userCoordinates)
                mapView2.animate(toZoom: zoomSetting)
                mapView2.animate(toLocation: userCoordinates)
            }
        }
    }
    
    func setSharedMode() {
        mapViewArea2.isHidden = false;
        mapViewFull.isMyLocationEnabled = true
        mapViewFull.settings.myLocationButton = true
        if let userCoordinates = locationManager.location?.coordinate {
            if user!["follow"] as? String != ""{
                let otherUserCoordinates = loadOtherUserData()
                let path = GMSMutablePath()
                path.add(userCoordinates)
                path.add(otherUserCoordinates)
                let bounds = GMSCoordinateBounds(path: path)
                mapViewFull.animate(with: GMSCameraUpdate.fit(bounds,withPadding: 50))
                setuplocationMarker(coordinate: otherUserCoordinates)
            }
            else {
                mapViewFull.animate(toZoom: zoomSetting)
                mapViewFull.animate(toLocation: userCoordinates)
            }
        }
    }
    
    func setSoloMode() {
        mapViewArea2.isHidden = false;
        mapViewFull.isMyLocationEnabled = true
        mapViewFull.settings.myLocationButton = true
        if user!["follow"] as? String != ""{
            let otherUserCoordinates = loadOtherUserData()
            mapViewFull.animate(toZoom: zoomSetting)
            mapViewFull.animate(toLocation: otherUserCoordinates)
            setuplocationMarker(coordinate: otherUserCoordinates)
        }
        else {
            if let userCoordinates = locationManager.location?.coordinate {
                mapViewFull.animate(toZoom: zoomSetting)
                mapViewFull.animate(toLocation: userCoordinates)
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
        locationMarker.isFlat = false
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
                query!.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        if let objects = objects {
                            for object in objects {
                                self.otherUser = object
                            }
                        }
                        let otherUserCoordinates = self.loadOtherUserData() as CLLocationCoordinate2D!
                        self.setuplocationMarker(coordinate: otherUserCoordinates!)
                    } else {
                        print("Error: \(error!) \(error!.localizedDescription)")
                    }
                })
            }
        }
    }
    

    
    // changes mode displayed (split, shared, or solo) based on slider
    @IBAction func sliderLetGo(_ sender: UISlider) {
        sender.setValue(Float(roundf(sender.value)), animated: false)
        mapMode()
    }
    
    // controls actions on press of return buttons on map (should return to current place)
    @IBAction func onMapFullReturn(_ sender: Any) {
        mapMode()
    }

    @IBAction func onMap1Return(_ sender: Any) {
        if user!["follow"] as! String != ""{
            let otherUserCoordinates = loadOtherUserData()
            mapView1.animate(toZoom: 13)
            mapView1.animate(toLocation: otherUserCoordinates)
            setuplocationMarker(coordinate: otherUserCoordinates)
        }
        else {
            if let UserCoordinates = locationManager.location?.coordinate {
                mapView1.animate(toZoom: 13)
                mapView1.animate(toLocation: UserCoordinates)
            }
        }
        
    }
    
    @IBAction func onMap2Return(_ sender: Any) {
        if let UserCoordinates = locationManager.location?.coordinate {
            mapView2.animate(toZoom: 13)
            mapView2.animate(toLocation: UserCoordinates)
        }
    }

    // methods to manage presentation of menuView
    @IBAction func openMenu(_ sender: Any) {
        showMenu()
    }
    
    @IBAction func onMenuFindMe(_ sender: Any) {
        hideMenu()
    }
    
    @IBAction func touchToMenu(_ sender: Any) {
        hideMenu()
    }

    func showMenu(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.menuBarView.center.x += self.menuBarView.frame.width
            self.grayoutView.alpha = 0.5
            
        }, completion: { finished in
            print("menu bar opened!")
        })
    }
    
    func hideMenu(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.menuBarView.center.x -= self.menuBarView.frame.width
            self.grayoutView.alpha = 0
        }, completion: { finished in
            print("menu bar closed!")
        })
        viewDidAppear(false)
    }
    
    var track: Bool?
    
    @IBAction func changeTracking(_ sender: Any) {
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
