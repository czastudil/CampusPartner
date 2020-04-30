//
//  Navigation_Search.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 2/7/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import UIKit
import MapboxGeocoder
import MapKit
import CoreLocation

class NavigationSearchController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var fromSearch: UISearchBar!
    @IBOutlet weak var destSearch: UISearchBar!
    @IBOutlet weak var routeButton: UIButton!
    var destCoord: CLLocationCoordinate2D!
    var sourceCoord: CLLocationCoordinate2D!
    var mapViewController: NavigationMapController!
    
    var currLocation: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromSearch.delegate = self
        destSearch.delegate = self
        routeButton.isEnabled = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currLocation = manager.location?.coordinate
        print("locations = \(locValue.latitude), \(locValue.longitude)")
    }
    
    // Once pressed by the user it will perform the following
    //      1. Validate that there is a location in the "To" search box
    //      2. Validate that there is a location in the "From" search box
    //      3. Make an API call to the GraphHopper API to retrieve the route
    @IBAction func generateRoute(_ sender: Any) {
        // Making sure there are locations in both fields
        if fromSearch.text == "Current Location" {
            self.mapViewController.sourceName = "Saved coordinates"
            sourceCoord = currLocation
        }
        
        // When simulating, make sure scheme is set up to have a default location simulated, otherwise will falsely show alert
        if sourceCoord == nil || destCoord == nil {
           
            let alert = UIAlertController(title: "Required Field(s) Missing", message: "One or more of the required fields is missing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
            return
        } else {
            self.mapViewController!.createRoute(sourceCoord: sourceCoord, destCoord: destCoord)
        }
    }
    
    /* When a user clicks the Search (Return) button after filling in the search bar,
     * the result is retrieved from the Mapbox Geocoding API.
     * Then, the search is replaced with its qualified name.
     * After this has occured, pins are dropped on the source and destination location
    */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //let geocoder = Geocoder.shared
        // Searching doesn't work when accessing the API key in the way below
        var accessToken = ""
        if let value = ProcessInfo.processInfo.environment["MAPBOX_API_KEY"] {
            accessToken = value
        }
        let geocoder = Geocoder(accessToken: accessToken)
        let options = ForwardGeocodeOptions(query: searchBar.text!)
        options.focalLocation = CLLocation(latitude: currLocation.latitude, longitude: currLocation.longitude)
        
        _ = geocoder.geocode(options) { (placemarks, attribution, error) in
            // Determine if any search results were returned
            guard let placemark = placemarks?.first else {
                let alert = UIAlertController(title: "No Results Found", message: "No results were found for your provided search term(s), please try another search.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true)
                return
            }
            
            // Save the coordinate & print out debugging information about the search result
            print(placemark.name)
            print(placemark.qualifiedName!)
            let coordinate = placemark.location!.coordinate
            print("\(coordinate.latitude), \(coordinate.longitude)")
            searchBar.text = placemark.qualifiedName!
            
            if let annotations = self.mapViewController!.mapView.annotations {
                self.mapViewController!.mapView.removeAnnotations(annotations)
            }
            
            if searchBar == self.destSearch {
                self.destCoord = coordinate
                self.mapViewController!.createPin(coord: self.destCoord!, coordType: "dest")
                self.mapViewController.destName = placemark.qualifiedName!
            } else if searchBar == self.fromSearch {
                self.sourceCoord = coordinate
                self.mapViewController!.createPin(coord: self.sourceCoord!, coordType: "source")
                self.mapViewController.sourceName = placemark.qualifiedName!
            } else {
                print("Something went wrong when detecting search bar.")
            }
        }
    }
    
    /* Indicates that the text in the search bar should be replaced by the qualified name of the location
     * being searched for
     */
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        return true
    }
}
