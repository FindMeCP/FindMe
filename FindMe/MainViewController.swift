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
    @IBOutlet weak var mapViewArea: UIView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    let locationManager = CLLocationManager()
    
    
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
            mapView1.myLocationEnabled = true
            mapView1.settings.myLocationButton = true
            mapView2.myLocationEnabled = true
            mapView2.settings.myLocationButton = true
            let NYCoordinates = CLLocationCoordinate2DMake(40.72, -74)
            mapView1.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            mapView2.camera = GMSCameraPosition(target: NYCoordinates, zoom: 12, bearing: 0, viewingAngle: 0)
            if let UserCoordinates = locationManager.location?.coordinate {
                mapView2.camera = GMSCameraPosition(target: UserCoordinates, zoom: 15, bearing: 0, viewingAngle: 0)
            }
        case .Restricted:
            print("restricted")
            // restricted by e.g. parental controls. User can't enable Location Services
        case .Denied:
            print("not authorized")
            // user denied your app access to Location Services, but can grant access from Settings.app
        }

        if self.revealViewController() != nil {
            settingsButton.target = self.revealViewController()
            settingsButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func onSlider(sender: UISlider) {
        sender.setValue(Float(roundf(sender.value)), animated: false)
    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView2.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            //locationManager.stopUpdatingLocation()
        }
        
    }
    
}
