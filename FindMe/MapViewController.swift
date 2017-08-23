//
//  MapViewController.swift
//  FindMe
//
//  Created by William Tong on 1/2/17.
//  Copyright © 2017 William Tong. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
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
    
    var timerTest : Timer?
    
    // Parse User objects for current user and user being followed
    var currentUser: User?
    var otherUser: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        FriendsAPI.instance.getUser(userID!) { (user) in
            self.currentUser = user
            self.usernameLabel.text = self.currentUser?.name
            self.secondMapTitle.text = self.currentUser?.name
            self.loadingView.isHidden = false
            self.loadFollowedUser()
            
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                print("not determined")
            case .authorizedWhenInUse:
                print("authorized when in use")
            case .authorizedAlways:
                print("authorized always")
                self.locationManager.startUpdatingLocation()
                if self.currentUser!.tracking! {
                    self.startTimer()
                }
            case .restricted:
                print("restricted")
            // restricted by e.g. parental controls. User can't enable Location Services
            case .denied:
                print("not authorized")
                // user denied your app access to Location Services, but can grant access from Settings.app
            }
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let userID = FIRAuth.auth()?.currentUser?.uid

        FriendsAPI.instance.getUser(userID!) { (user) in
            self.currentUser = user
            self.usernameLabel.text = self.currentUser?.name
            self.secondMapTitle.text = self.currentUser?.name
            self.loadingView.isHidden = false
            
            self.loadFollowedUser()
            
            if let userTracking = self.currentUser?.tracking {
                self.trackingButton.isOn = userTracking
                self.track = userTracking
            }else{
                self.trackingButton.isOn = false
                self.track = false
            }
        }
    }
    
    // retrieves the person being followed by current user (if any) and assigns to global variable otherUser
    func loadFollowedUser() {
        if let otherUserID = currentUser?.follow {
            if currentUser!.tracking! && otherUserID != "" {
                // get other user from id
                FriendsAPI.instance.getUser(otherUserID, completion: { (user) in
                    self.otherUser = user
                    if let trackOtherUser = self.otherUser?.tracking {
                        if(trackOtherUser){
                            let otherUserCoordinates = self.loadOtherUserData() as CLLocationCoordinate2D!
                            self.setuplocationMarker(coordinate: otherUserCoordinates!)
                            let friendName = self.otherUser?.name
                            self.firstMapTitle.text = friendName
                        }else{
                            self.firstMapTitle.text = "Follow a Friend!"
                        }
                    }
                    self.mapMode()
                    self.loadingView.isHidden = true
                })
            }
            else {
                otherUser = nil
                firstMapTitle.text = "Follow a Friend!"
                mapMode()
                loadingView.isHidden = true
                
                if locationMarker != nil {
                    locationMarker.map = nil
                }
            }
        }
        else {
            otherUser = nil
            firstMapTitle.text = "Follow a Friend!"
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
        if currentUser!.tracking && currentUser?.follow != "" && otherUser != nil && otherUser!.tracking{
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
            if currentUser!.tracking && currentUser?.follow != "" && otherUser != nil && otherUser!.tracking{
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
        if currentUser!.tracking && currentUser?.follow != "" && otherUser != nil && otherUser!.tracking{
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
        locationMarker.title = otherUser?.name
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.isFlat = false
        locationMarker.snippet = "Time Stamp"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = NSDate(timeIntervalSince1970: otherUser!.timestamp)
        print(date)
        let myString = formatter.string(from: date as Date)
        print(myString)
        locationMarker.snippet =  myString
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
        
        if otherUser != nil {
            if let coordinates = otherUser?.coordinates {
                if coordinates != (0,0){
                    Lat = coordinates.0
                    Long = coordinates.1
                    
                    
                } else{
                    print("If let not working")
                }
            }
            
        }
        return CLLocationCoordinate2DMake(Lat, Long)
    }
    
    // checks to see if current user's tracking is turned on.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location manager")
        print(currentUser ?? "user not logged in")
        if currentUser != nil {
            if let tracking = currentUser?.tracking {
                if(tracking){
                    print("Tracking is on!")
                    let latitude = locationManager.location?.coordinate.latitude
                    let longitude = locationManager.location?.coordinate.longitude
                    //updates user coordinates
                    FriendsAPI.instance.updateUserLocation(currentUser!.id, coordinates: (latitude!,longitude!))
                }
            }

        }
    }
    
    func timedPinUpdate()
    {
        print("updating")
        if currentUser?.follow != "" {
            if let otherUserID = currentUser?.follow {
                FriendsAPI.instance.getUser(otherUserID, completion: { (user) in
                    self.otherUser = user
                    let otherUserCoordinates = self.loadOtherUserData() as CLLocationCoordinate2D!
                    self.setuplocationMarker(coordinate: otherUserCoordinates!)
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
        if currentUser?.follow != ""{
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
    
    
    func startTimer() {
        if timerTest == nil {
            print("Starting timer")
            timerTest = Timer.scheduledTimer(timeInterval: 1500.0, target: self, selector: #selector(MapViewController.timedPinUpdate), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        print("trying to stop timer")
        if timerTest == nil {
            print("timer is nil")
        }
        if timerTest != nil {
            print("TIMER STOPPING")
            timerTest!.invalidate()
            timerTest = nil
        }
    }
    
    var track: Bool?
    
    @IBAction func changeTracking(_ sender: Any) {
        if(track!){
            print("turn off")
            track = false
            FriendsAPI.instance.changeTracking(track!)
            currentUser?.tracking = track
        }else{
            print("turn on")
            track = true
            FriendsAPI.instance.changeTracking(track!)
            currentUser?.tracking = track
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let logoutAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out ? ", preferredStyle: UIAlertControllerStyle.alert)
        
        logoutAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            FriendsAPI.instance.logoutAccount()
            self.locationManager.stopUpdatingLocation()
            self.currentUser = nil
            self.stopTimer()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.userDidLogout()
        }))
        
        logoutAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            logoutAlert .dismiss(animated: true, completion: nil)
        }))
        
        present(logoutAlert, animated: true, completion: nil)
    }

    
    deinit {
        print("MapViewController was deallocated")
    }
}
