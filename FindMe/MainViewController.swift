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
    @IBOutlet weak var mapViewArea: UIView!
    @IBOutlet weak var firstMapView: MKMapView!
    @IBOutlet weak var secondMapView: MKMapView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let logo = UIImage(named: "FindMeLogoSmallPurple")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .ScaleAspectFit
        
        self.navigationItem.titleView = imageView
        
        
        
        
        
        firstMapView.frame = CGRectMake(0 , 0, mapViewArea.frame.width, mapViewArea.frame.height/2)
        print(mapViewArea.frame.height/2)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            //WILL UPDATE LOCATION ?
            locationManager.startUpdatingLocation()
        }
        firstMapTitle.text = "New York"
        let NYCoordinates = CLLocationCoordinate2DMake(40.72, -74)
        secondMapTitle.text = "User"
        let userCoordinates = locationManager.location!.coordinate
        let firstRegion = MKCoordinateRegionMakeWithDistance(NYCoordinates, 4000, 4000)
        let secondRegion = MKCoordinateRegionMakeWithDistance(userCoordinates, 4000, 4000)
        
        
        firstMapView.setRegion(firstRegion, animated: true)
        secondMapView.setRegion(secondRegion, animated: true)
        
        
//        For two pins in one?
        
//        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:middlePoint.latitude longitude:middlePoint.longitude];
//        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:pointB.latitude longitude:pointB.longitude];
//        CLLocationDistance d = [pointALocation distanceFromLocation:pointBLocation];
//        MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(middlePoint, 2*d, 2*d);
//        [mapView setRegion:r animated:YES];
        
        if self.revealViewController() != nil {
            settingsButton.target = self.revealViewController()
            settingsButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func onSlider(sender: UISlider) {
        sender.setValue(Float(roundf(sender.value)), animated: false)
    }
    
    
    @IBAction func onFirstMapReturn(sender: AnyObject) {
        let NYCoordinates = CLLocationCoordinate2DMake(40.72, -74)
        let firstRegion = MKCoordinateRegionMakeWithDistance(NYCoordinates, 4000, 4000)
        firstMapView.setRegion(firstRegion, animated: true)
    }
    
    
    @IBAction func onSecondMapReturn(sender: AnyObject) {
        let userCoordinates = locationManager.location!.coordinate
        let secondRegion = MKCoordinateRegionMakeWithDistance(userCoordinates, 4000, 4000)
        secondMapView.setRegion(secondRegion, animated: true)
    }
   
    
}
