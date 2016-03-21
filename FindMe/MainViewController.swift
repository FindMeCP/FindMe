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

class MainViewController: UIViewController {
    @IBOutlet weak var firstMapView: MKMapView!
    @IBOutlet weak var secondMapView: MKMapView!
    
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
        let firstRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.8, -122.42),
            MKCoordinateSpanMake(0.1, 0.1))
        
        let secondRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.8, -122.42),
            MKCoordinateSpanMake(0.1, 0.1))
        
        firstMapView.setRegion(firstRegion, animated: false)
        secondMapView.setRegion(secondRegion, animated: false)
        
        if self.revealViewController() != nil {
            settingsButton.target = self.revealViewController()
            settingsButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()

    }
    
   
    
}
