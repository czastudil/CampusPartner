//
//  Navigation-Map.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 2/7/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import CoreLocation

class NavigationMapController: UIViewController, MGLMapViewDelegate {
    
    var mapView: NavigationMapView!
    var navParent: Navigation!
    var directionsRoute: Route?
    var routeResponse: URLResponse?
    var responseData: Data?
    var responseCoords: [CLLocation]?
    var sourceCoordinate : CLLocationCoordinate2D?
    var destCoordinate : CLLocationCoordinate2D?
    var addedSourcePin: MGLAnnotation?
    var addedDestPin: MGLAnnotation?
    var routePath: RoutePath?
    var sourceName = ""
    var destName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = NavigationMapView(frame: view.bounds)
        
        view.addSubview(mapView)
        
        // Set the map view's delegate
        mapView.delegate = self
        
        // Allow the map to display the user's location with their heading
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true, completionHandler: nil)
        mapView.showsUserHeadingIndicator = true
        mapView.setCenter(CLLocationCoordinate2D(latitude: 38.435386, longitude:  -78.869712), zoomLevel: 22, animated: true)
    }
    
    // Creates a pin for the given coordinate (currently using the default style from Mapbox
    func createPin(coord : CLLocationCoordinate2D, coordType: String) {
        let point = MGLPointAnnotation()
        var pointAnnotations = [MGLPointAnnotation]()
        point.coordinate = coord
        point.title = "\(coord.latitude), \(coord.longitude)"
        pointAnnotations.append(point)
        
        if coordType == "source" {
            addedSourcePin = point
        } else if coordType == "dest" {
            addedDestPin = point
        }
        
        if addedDestPin != nil && coordType != "dest" {
            print("Appending existing dest annotation")
            pointAnnotations.append(addedDestPin as! MGLPointAnnotation)
        } else if addedSourcePin != nil && coordType != "source" {
            print("Appending existing source annotation")
            pointAnnotations.append(addedSourcePin as! MGLPointAnnotation)
        }
        
        mapView.addAnnotations(pointAnnotations)
    }
    
    // Generate route function with API call - GraphHopper version
    // TODO: avoid showing the API key in final version pushed to GitHub/GitLab
    func createRoute(sourceCoord: CLLocationCoordinate2D, destCoord: CLLocationCoordinate2D) {
        var accessToken = ""
        if let value = ProcessInfo.processInfo.environment["GH_API_KEY"] { 
            accessToken = value
        }
        //let routing = Routing(accessToken: "4da5c68a-11b1-4e12-a975-dc1737067702")
        let routing = Routing(accessToken: accessToken)
        let defaults = UserDefaults.standard
        let points = [sourceCoord, destCoord]
        self.destCoordinate = destCoord
        self.sourceCoordinate = sourceCoord
        let options = RouteOptions(points: points)
        // Options: vehicle, elevation, details, points_encoded, ch.disable = true, avoid
        options.elevation = true
        options.instructions = true
        options.vehicle = .foot
        options.calculatePoints = true
        options.disable = true
        options.encodePoints = false
        if (defaults.bool(forKey: "avoidStairs")) {
            options.avoid = "steps"
        }
        
        let _ = routing.calculate(options, completionHandler: { (paths, error) in
            
            if paths == nil {
                let alert = UIAlertController(title: "No Routes Found", message: "No routes for your profile could be found for your provided source and destination.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true)
                return
            }
            
            paths?.forEach({path in
                self.routePath = path
                self.responseCoords = path.points
                self.setRouteSteps(path: path)
                self.navParent.bbox = MGLCoordinateBounds(sw: path.bbox!.bottomRight, ne: path.bbox!.topLeft)
                self.mapView.setVisibleCoordinateBounds(MGLCoordinateBounds(sw: path.bbox!.bottomRight, ne: path.bbox!.topLeft), animated: true)
            })
            self.buildRoute(sourceCoord: sourceCoord, destCoord: destCoord)   
        })
    }
    
    // Gets all of the route steps to show in the Navigation parent class
    // I don't think this works correctly, probably use the getCoordinate method to determine coefficients,
    // need to determine the interval (in terms of the coordinates) for each instruction
    func setRouteSteps(path: RoutePath) {
        let insts = path.instructions
        let dists = path.legDistances
        let times = path.legTimes
        //var endIndex = 0
        let intervals = path.instructionIntervals
        
        var routeSteps = [RouteStep]()
        for (index, _) in insts.enumerated() {
            let minute : Double = times[index] / 60000.0
            let sec : Double = times[index].truncatingRemainder(dividingBy: 60000.0) / 1000.0
            let feet : Double = dists[index] * 3.281
            
            let curInt : [Int] = intervals[index]
            let start = curInt[0]
            let end = curInt[1]
            var coords = [CLLocationCoordinate2D]()
            for i in start...end {
                coords.append(responseCoords![i].coordinate)
            }
            
            print("Instruction \(index) with coordinates: \(coords)")
            // Get the interval from the instruction
            //let endCoord : CLLocationCoordinate2D = self.responseCoords![index + 1].coordinate
            let rs : RouteStep = RouteStep(instruction: insts[index].text, distance: Int(feet.rounded()), timeMin: minute.rounded(toPlaces: 2), timeSec: sec.rounded(toPlaces: 2), interval: coords)
            routeSteps.append(rs)
        }
        
        self.navParent.routeSteps = routeSteps
    }
    
    // Generates the button which indicates the parent class should show the route overlay
    func buildRoute(sourceCoord: CLLocationCoordinate2D, destCoord: CLLocationCoordinate2D) {
        let yVal1 : CGFloat = self.view.center.y + 190
        let xVal1 : CGFloat = 25
        let button = UIButton(frame: CGRect(x: xVal1, y: yVal1, width: 175, height: 50))
        button.setTitle("Begin Route", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.backgroundColor = UIColor(rgb: 0x333333)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        self.view.bringSubviewToFront(button)
        
        let xVal2: CGFloat = self.view.bounds.width - 200
        let yVal2: CGFloat = self.view.center.y + 190
        let saveButton = UIButton(frame: CGRect(x: xVal2, y: yVal2, width: 175, height: 50))
        saveButton.setTitle("Save Route", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        saveButton.backgroundColor = UIColor(rgb: 0x333333)
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 1
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        self.view.addSubview(saveButton)
        self.view.bringSubviewToFront(saveButton)
        drawRoute()
    }
    
    // Calls function in Navigation parent class
    @objc func buttonAction(sender: UIButton!) {
        self.navParent.beginNavigation()
    }
    
    // Saves the route for loading later
    @objc func saveButtonAction(sender: UIButton!) {
        var routeTitle: String
        var sName: String
        if !sourceName.isEmpty {
            routeTitle = "\(self.sourceName) -> \(self.destName)"
            sName = self.sourceName
        } else {
            routeTitle = "Saved coordinates -> \(self.destName)"
            sName = "Current Location"
        }
    
        
        let route = Route(routeTitle: routeTitle, sourceName: sName, destName: self.destName)
        routes.append(route)
        print(routes)
    }
    
    // Creates a list of the route coordinates needed to draw a polyline on the map view
    func getCoordinateList() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        // Getting an error here??
        self.responseCoords!.forEach({ point in
            coords.append(point.coordinate)
        })
        return coords
    }
    
    // Draws the route on the map view below the search bar
    func drawRoute() {
        // Convert the route’s coordinates into a polyline
        let routeCoordinates: [CLLocationCoordinate2D] = getCoordinateList()
        let polyline = MGLPolylineFeature(coordinates: routeCoordinates, count: UInt(routeCoordinates.count))
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            // This is the logic being used in this application (this code is modified from a Mapbox example)
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
            
            // Add the source and style layer of the route line to the map
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

