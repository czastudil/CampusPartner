//
//  Navigation.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 2/6/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import UIKit
import CoreLocation
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class Navigation: UIViewController, UITableViewDataSource, UITableViewDelegate, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    // Access to these variables is not private because they are accessed by the child view mapViewController
    open var routeSteps: [RouteStep]?
    open var bbox : MGLCoordinateBounds?
    open var savedRouteIndex = -1
    
    private var locationSearchViewController : NavigationSearchController?
    private var mapViewController : NavigationMapController?
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let tableView = UITableView()
    private var routeStepView : NavigationMapView?
    private var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    private var button : UIButton?
    private var gomapView : NavigationMapView?
    private var gomapVisible = false
    private let locationManager = CLLocationManager()
    private var currentStep = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(rgb: 0xF4EFE1)
        
        // Make sure the children are present in the storyboard
        guard let locationSearchViewController = children.first as? NavigationSearchController else  {
            fatalError("Check storyboard for missing LocationTableViewController")
        }
        guard let mapViewController = children.last as? NavigationMapController else {
            fatalError("Check storyboard for missing MapViewController")
        }
        
        // Set up the child views: searching and the mini-map
        self.locationSearchViewController = locationSearchViewController
        self.mapViewController = mapViewController
        if let _ = self.locationSearchViewController {
            self.locationSearchViewController!.mapViewController = self.mapViewController
        }
        self.mapViewController?.navParent = self
        
        // Add the gesture recognizer to exit the navigation steps table view
        self.screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(exitNav))
        self.screenEdgeRecognizer.edges = .left
        view.addGestureRecognizer(self.screenEdgeRecognizer)
        
        // Set up the route step mapping view
        self.routeStepView = NavigationMapView(frame: view.bounds)
        self.routeStepView!.delegate = self
        self.routeStepView!.showsUserLocation = true
        self.routeStepView!.setUserTrackingMode(.followWithHeading, animated: true, completionHandler: nil)
        self.routeStepView!.showsUserHeadingIndicator = true
        self.view.addSubview(routeStepView!)
        self.view.sendSubviewToBack(routeStepView!)
        
        // Set up the back button to exit the route step mapping view
        let yVal : CGFloat = 35
        let xVal : CGFloat = 10
        self.button = UIButton(frame: CGRect(x: xVal, y: yVal, width: 50, height: 30))
        self.button!.setTitle("Back", for: .normal)
        self.button!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.button!.backgroundColor = UIColor(rgb: 0x333333)
        self.button!.layer.cornerRadius = 5
        self.button!.layer.borderWidth = 1
        self.button!.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(self.button!)
        self.view.sendSubviewToBack(self.button!)
        
        self.gomapView = NavigationMapView(frame: self.view.bounds)
        self.gomapView!.delegate = self
        self.gomapView!.showsUserLocation = true
        self.gomapView!.setUserTrackingMode(.followWithHeading, animated: true, completionHandler: nil)
        
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.savedRouteIndex > -1 {
            self.locationSearchViewController!.fromSearch.text = routes[self.savedRouteIndex].sourceName
            self.locationSearchViewController!.destSearch.text = routes[self.savedRouteIndex].destName
            self.locationSearchViewController!.currLocation = locationManager.location?.coordinate
            self.locationSearchViewController!.searchBarSearchButtonClicked(locationSearchViewController!.fromSearch)
            self.locationSearchViewController!.searchBarSearchButtonClicked(locationSearchViewController!.destSearch)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.savedRouteIndex = -1
    }
    
    // TODO: Test this on an actual device
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        if (self.tableView.isDescendant(of: self.view)) {
            var minDist = Double.greatestFiniteMagnitude
            var minIndex = 1000000
            for (index, _) in self.routeSteps!.enumerated() {
                let start = self.routeSteps![index].interval![0]
                let distance = locValue.distance(to: start)
                if distance < minDist {
                    minIndex = index
                    minDist = distance
                }
            }
            self.currentStep = minIndex
            print(minIndex)
        }
    }
    
    // Indicates that the table view should be hidden and show the user the map/search view again
    @objc func exitNav(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .ended && self.tableView.isDescendant(of: self.view) {
            self.tableView.removeFromSuperview()
            let alert = UIAlertController(title: "Missing or Inaccurate Data?", message: "Do you want to navigate to Go Map to fix any missing or inaccurate data?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPress(_:)))
                self.gomapView!.addGestureRecognizer(longPress)
                
                if let annotations = self.gomapView!.annotations {
                    self.gomapView!.removeAnnotations(annotations)
                }
                self.view.addSubview(self.gomapView!)
                self.view.bringSubviewToFront(self.gomapView!)
                self.view.bringSubviewToFront(self.button!)
                self.gomapView!.setVisibleCoordinateBounds(self.bbox!, animated: true)
                self.drawRoute(mapView: self.gomapView!)
                self.gomapVisible = true
                
            }
            alert.addAction(yesAction)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: self.gomapView!)
        let coordinate = self.gomapView!.convert(point, toCoordinateFrom: self.gomapView!)
        
        // Create a basic point annotation and add it to the map
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Go Map edit location"
        self.gomapView!.addAnnotation(annotation)
        
        let alert = UIAlertController(title: "Edit Location in Go Map?", message: "Is this the location you would like to edit in Go Map?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            let gomapString = "gomaposm://?center=\(coordinate.latitude),\(coordinate.longitude)&zoom=18"
            let gomapURL = URL(string: gomapString)
            
            if UIApplication.shared.canOpenURL(gomapURL!) {
                UIApplication.shared.open(gomapURL!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(URL(string: "itms://apps.apple.com/us/app/go-map/id592990211")!, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(yesAction)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // Creates a full screen overlay for showing the navigation steps
    func beginNavigation() {
        var safeArea: UILayoutGuide!
        safeArea = view.layoutMarginsGuide
        view.addSubview(self.tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.tableView.register(RouteStepTableViewCell.self, forCellReuseIdentifier: "routeStepCell")
    }
    
    /*
     BEGIN TABLE VIEW FUNCTIONS
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.routeSteps!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeStepCell", for: indexPath) as! RouteStepTableViewCell
        cell.routeStep = self.routeSteps![indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Navigation Steps"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let width : CGFloat = self.view.frame.width
        let height : CGFloat = self.view.frame.height * CGFloat(0.1)
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = UIFont.boldSystemFont(ofSize: 24)
        header.textLabel!.textColor = .black
        //header.textLabel!.backgroundColor = .white
        //header.backgroundView!.backgroundColor = .white
    }
    
    func tableView(_ tableView: UITableView, willDisplay: UITableViewCell, forRowAt: IndexPath) {
        if forRowAt.item == self.currentStep {
            willDisplay.backgroundColor = UIColor(rgb: 0x8EE4D7)
        } else {
            willDisplay.backgroundColor = .white
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRouteStep = self.routeSteps?[indexPath.row]
        
        if let annotations = self.routeStepView!.annotations {
            self.routeStepView!.removeAnnotations(annotations)
        }
        self.view.bringSubviewToFront(self.routeStepView!)
        self.drawRouteStep(stepCoords: (selectedRouteStep?.interval!)!)
        self.createPin(coord: (selectedRouteStep?.interval![0])!)
        let end = selectedRouteStep?.interval!.count
        self.createPin(coord: (selectedRouteStep?.interval![end!-1])!)
        self.view.bringSubviewToFront(self.button!)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     END TABLE VIEW FUNCTIONS
    */
    
    /*
     BEGIN ROUTE STEP VIEW FUNCTIONS
    */
 
    @objc func buttonAction(sender: UIButton!) {
        if !self.gomapVisible {
            self.view.sendSubviewToBack(self.routeStepView!)
        } else {
            self.view.sendSubviewToBack(self.gomapView!)
        }
        self.view.sendSubviewToBack(self.button!)
    }
    
    func drawRouteStep(stepCoords: [CLLocationCoordinate2D]) {
        // Convert the route’s coordinates into a polyline
        let polyline = MGLPolylineFeature(coordinates: stepCoords, count: UInt(stepCoords.count))
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = self.routeStepView!.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
            
            // Add the source and style layer of the route line to the map
            self.routeStepView!.style?.addSource(source)
            self.routeStepView!.style?.addLayer(lineStyle)
        }
    }
    
    func createPin(coord : CLLocationCoordinate2D) {
        var pointAnnotations = [MGLPointAnnotation]()
        
        let point = MGLPointAnnotation()
        point.coordinate = coord
        point.title = "\(coord.latitude), \(coord.longitude)"
        pointAnnotations.append(point)
        
        self.routeStepView!.addAnnotations(pointAnnotations)
    }

    /*
     END ROUTE STEP VIEW FUNCTIONS
    */
    
    // Draws the route for selected a point on the map for navigation to the Go Map application
    func drawRoute(mapView : NavigationMapView) {
        // Convert the route’s coordinates into a polyline
        let routeCoordinates: [CLLocationCoordinate2D] = self.mapViewController!.getCoordinateList()
        let polyline = MGLPolylineFeature(coordinates: routeCoordinates, count: UInt(routeCoordinates.count))
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = self.gomapView?.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
            
            // Add the source and style layer of the route line to the map
            self.gomapView?.style?.addSource(source)
            self.gomapView?.style?.addLayer(lineStyle)
        }
    }
}

// Extends UIColor to provide a convient init function for creating a color from a hex code.
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
