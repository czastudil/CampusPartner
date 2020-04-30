//
//  File.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 4/29/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import UIKit
import CoreLocation

class HelpView: UIViewController, CLLocationManagerDelegate {
    
    var currLocation: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currLocation = manager.location?.coordinate
    }
    
    @IBAction func gomapTutorial(_ sender: Any) {
        if let url = NSURL(string: "https://wiki.openstreetmap.org/wiki/Go_Map!!") {
            UIApplication.shared.open(url as URL, options:[:], completionHandler:nil)
        }
    } 
    
    @IBAction func openGoMap(_ sender: Any) {
        let gomapString = "gomaposm://?center=\(currLocation.latitude),\(currLocation.longitude)&zoom=18"
        let gomapURL = URL(string: gomapString)
        
        if UIApplication.shared.canOpenURL(gomapURL!) {
            UIApplication.shared.open(gomapURL!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(URL(string: "itms://apps.apple.com/us/app/go-map/id592990211")!, options: [:], completionHandler: nil)
        }
    }
}
