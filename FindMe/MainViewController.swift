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
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    let locationManager = CLLocationManager()
    let user = PFUser.currentUser()
    var locationMarker: GMSMarker!
    var otherUser: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.hidden = false
        let query = PFUser.query()
        query!.whereKey("phone", equalTo: "3146022911")
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
                self.mapMode()
                self.loadingView.hidden = true
                print("map fully loaded")
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        let logo = UIImage(named: "FindMeLogoSmallPurple")
        
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        firstMapTitle.text = "New York"
        secondMapTitle.text = "User"
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .NotDetermined:
            print("not determined")
        case .AuthorizedWhenInUse:
            print("authorized when in use")
        case .AuthorizedAlways:
            print("authorized always")
            locationManager.startUpdatingLocation()
        case .Restricted:
            print("restricted")
        // restricted by e.g. parental controls. User can't enable Location Services
        case .Denied:
            print("not authorized")
            // user denied your app access to Location Services, but can grant access from Settings.app
        }
        
        if self.revealViewController() != nil {
            settingsButton.target = self.revealViewController()
            settingsButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }
    @IBAction func onMapFullReturn(sender: AnyObject) {
        mapMode()
    }
   
    @IBAction func onMap1Return(sender: AnyObject) {
        let otherUserCoordinates = loadOtherUserData()
        mapView1.animateToZoom(13)
        mapView1.animateToLocation(otherUserCoordinates)
        
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
        let NYCoordinates = CLLocationCoordinate2DMake(40.72, -74)
        if (mapModeSlider.value == 0){
            print("split mode")
            mapViewArea2.hidden = true;
            mapView1.myLocationEnabled = true
            mapView1.settings.myLocationButton = true
            mapView2.myLocationEnabled = true
            mapView2.settings.myLocationButton = true
            let otherUserCoordinates = loadOtherUserData()
            mapView1.animateToZoom(13)
            mapView1.animateToLocation(otherUserCoordinates)
            mapView2.animateToLocation(NYCoordinates)
            setuplocationMarker(otherUserCoordinates)
            if let UserCoordinates = locationManager.location?.coordinate {
                mapView2.animateToZoom(13)
                mapView2.animateToLocation(UserCoordinates)
            }
        }
        else if (mapModeSlider.value == 1){
            print("shared mode")
            mapViewArea2.hidden = false;
            mapViewFull.myLocationEnabled = true
            mapViewFull.settings.myLocationButton = true
            mapViewFull.camera = GMSCameraPosition(target: NYCoordinates, zoom: 13, bearing: 0, viewingAngle: 0)
            setuplocationMarker(NYCoordinates)
            if let UserCoordinates = locationManager.location?.coordinate {
                let otherUserCoordinates = loadOtherUserData()
                let path = GMSMutablePath()
                path.addCoordinate(UserCoordinates)
                path.addCoordinate(otherUserCoordinates)
                let bounds = GMSCoordinateBounds(path: path)
                mapViewFull.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds,withPadding: 50))
                setuplocationMarker(otherUserCoordinates)
            }
        }
        else if (mapModeSlider.value == 2){
            print("solo mode")
            let otherUserCoordinates = loadOtherUserData()
            mapViewArea2.hidden = false;
            mapViewFull.myLocationEnabled = true
            mapViewFull.settings.myLocationButton = true
            mapViewFull.animateToZoom(13)
            mapViewFull.animateToLocation(otherUserCoordinates)
            
            setuplocationMarker(otherUserCoordinates)
        }
    }
    
    func setuplocationMarker(coordinate: CLLocationCoordinate2D) {
        if locationMarker != nil {
            locationMarker.map = nil
        }
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.title = "Username"
        locationMarker.appearAnimation = kGMSMarkerAnimationNone
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
        if let userLat = otherUser["latitude"]{
            Lat = userLat as! Double
            Long = otherUser["longitude"] as! Double
            
        } else{
            print("If let not working")
        }
        return CLLocationCoordinate2DMake(Lat, Long)
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let query = PFUser.query()
        query!.whereKey("phone", equalTo: "3146022911")
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
        user!["latitude"] = locationManager.location?.coordinate.latitude
        user!["longitude"] = locationManager.location?.coordinate.longitude
        ///ADD USER TIME
        user!.saveInBackground()
    }

    
}
