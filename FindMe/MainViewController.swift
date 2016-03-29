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

class MainViewController: UIViewController, CLLocationManagerDelegate{
    @IBOutlet weak var firstMapTitle: UILabel!
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            //Probably wont be necessary, just choose one and do it later in the action
            
            if (mapModeSlider.value == 1){
                mapViewFull.myLocationEnabled = true
                mapViewFull.settings.myLocationButton = true
                let NYCoordinates = CLLocationCoordinate2DMake(40.72, -74)
                mapViewFull.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
                if let UserCoordinates = locationManager.location?.coordinate {
                    mapViewFull.camera = GMSCameraPosition(target: UserCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
                }
            }
            //            else if (mapModeSlider.value == 0){
            //                mapView1.myLocationEnabled = true
            //                mapView1.settings.myLocationButton = true
            //                mapView2.myLocationEnabled = true
            //                mapView2.settings.myLocationButton = true
            //                let NYCoordinates = CLLocationCoordinate2DMake(40.72, -74)
            //                mapView1.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            //                mapView2.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            //                if let UserCoordinates = locationManager.location?.coordinate {
            //                    mapView2.camera = GMSCameraPosition(target: UserCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            //                }
            //            }
            //            else if (mapModeSlider.value == 2){
            //                mapViewFull.myLocationEnabled = true
            //                mapViewFull.settings.myLocationButton = true
            //                let NYCoordinates = CLLocationCoordinate2DMake(40.72, -74)
            //                mapViewFull.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            //                if let UserCoordinates = locationManager.location?.coordinate {
            //                    mapViewFull.camera = GMSCameraPosition(target: UserCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            //                }
        //            }
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
    
    @IBAction func sliderLetGo(sender: UISlider) {
        sender.setValue(Float(roundf(sender.value)), animated: false)
        let NYCoordinates = CLLocationCoordinate2DMake(40.72, -74)
        if (mapModeSlider.value == 0){
            mapViewArea2.hidden = true;
            mapView1.myLocationEnabled = true
            mapView1.settings.myLocationButton = true
            mapView2.myLocationEnabled = true
            mapView2.settings.myLocationButton = true
            mapView1.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            mapView2.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            if let UserCoordinates = locationManager.location?.coordinate {
                mapView2.camera = GMSCameraPosition(target: UserCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            }
            setuplocationMarker(NYCoordinates)
        }
        else if (mapModeSlider.value == 1){
            mapViewArea2.hidden = false;
            mapViewFull.myLocationEnabled = true
            mapViewFull.settings.myLocationButton = true
            mapViewFull.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            if let UserCoordinates = locationManager.location?.coordinate {
                mapViewFull.camera = GMSCameraPosition(target: UserCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            }
            setuplocationMarker(NYCoordinates)
        }
        else if (mapModeSlider.value == 2){
            mapViewArea2.hidden = false;
            mapViewFull.myLocationEnabled = true
            mapViewFull.settings.myLocationButton = true
            mapViewFull.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            if let UserCoordinates = locationManager.location?.coordinate {
                mapViewFull.camera = GMSCameraPosition(target: UserCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            }
            setuplocationMarker(NYCoordinates)
        }
    }
    
    func setuplocationMarker(coordinate: CLLocationCoordinate2D) {
        if locationMarker != nil {
            locationMarker.map = nil
        }
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.title = "Nyck"
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.flat = true
        locationMarker.snippet = "NY User"
        if (mapModeSlider.value == 0){
            locationMarker.map = mapView1
        }
        else if (mapModeSlider.value == 1){
            locationMarker.map = mapViewFull
        }
        else if (mapModeSlider.value == 2){
            locationMarker.map = mapViewFull
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            //mapView2.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            //locationManager.stopUpdatingLocation()
            user!["latitude"] = locationManager.location?.coordinate.latitude
            user!["longitude"] = locationManager.location?.coordinate.latitude
            user!.saveInBackground()
        }
        
    }
    
}
