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
    @IBOutlet weak var firstMapView: MKMapView!
    @IBOutlet weak var secondMapView: MKMapView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            //WILL UPDATE LOCATION
            //locationManager.startUpdatingLocation()
        }
        let userLatitude = locationManager.location!.coordinate.latitude
        let userLongitude = locationManager.location!.coordinate.longitude
        
        print("location = \(userLatitude) \(userLongitude) ")
        
        //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
        let firstRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(40.7, -74),
            MKCoordinateSpanMake(0.1, 0.1))
        print(firstRegion)
        
        let secondRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(userLatitude, userLongitude),MKCoordinateSpanMake(0.01, 0.1))
        
        firstMapView.setRegion(firstRegion, animated: false)
        secondMapView.setRegion(secondRegion, animated: false)
        
        if self.revealViewController() != nil {
            settingsButton.target = self.revealViewController()
            settingsButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        //userLongitude = locValue.longitude
//        //userLatitude = locValue.latitude
//        //print("locations = \(locValue.latitude) \(locValue.longitude)")
//    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()

    }
    
   
    
}
